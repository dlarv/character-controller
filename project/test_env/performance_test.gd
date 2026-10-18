extends Node

signal finished
signal phase_done

const GD_CONTROL_PATH := "res://perf_logs/perf_gd_control.csv"
const GD_TEST_PATH := "res://perf_logs/perf_gd_test.csv"
const CPP_CONTROL_PATH := "res://perf_logs/perf_cpp_control.csv"
const CPP_TEST_PATH := "res://perf_logs/perf_cpp_test.csv"

@export var test_gd := true
@export var spawn_time := 10.0
@export var actions_performed := 3
@export var iterations := 13
@export var phases := 10

var gd_control_file: FileAccess
var gd_test_file: FileAccess
var cpp_control_file: FileAccess
var cpp_test_file: FileAccess
var end_action: InputEventAction
var do_control: bool

var _current_file: FileAccess

var _num := 1
var _timer: Timer
var _actions: Array[InputEventAction]
var _counter := 0

func _ready() -> void:
	gd_control_file = FileAccess.open(GD_CONTROL_PATH, FileAccess.READ_WRITE)
	gd_control_file.seek_end()
	gd_test_file = FileAccess.open(GD_TEST_PATH, FileAccess.READ_WRITE)
	gd_test_file.seek_end()
	cpp_control_file = FileAccess.open(GD_CONTROL_PATH, FileAccess.READ_WRITE)
	cpp_control_file.seek_end()
	cpp_test_file = FileAccess.open(GD_TEST_PATH, FileAccess.READ_WRITE)
	cpp_test_file.seek_end()

	_actions = []
	for i in actions_performed:
		for a in [ "ui_select",  "ui_up", "ui_down",  "ui_left", "ui_right" ]:
			var action = InputEventAction.new()
			action.action = a
			action.pressed = true
			_actions.append(action)

	end_action = InputEventAction.new()
	end_action.action = "sprint"
	end_action.pressed = true
	_actions.append(end_action)

	_timer = Timer.new()
	_timer.one_shot = true 
	_timer.wait_time = spawn_time
	_timer.autostart = false
	_timer.timeout.connect(_test)
	add_child(_timer)

	for i in phases:
		print("Phase %d" % i)
		await execute()


func execute() -> void:
	print("GD Control Start")
	do_control = true
	_current_file = gd_control_file
	_timer.start()
	await phase_done

	print("GD Test Start")
	do_control = false
	_current_file = gd_test_file
	_timer.start()
	await phase_done

	print("TESTING ENDED")


func _test() -> void:
	_counter = 0
	var start_spawn := Time.get_ticks_usec()
	for i in _num:
		var chara := StandardRBController.new()
		chara.sprint_action = "sprint"
		chara.dash_enabled = false
		chara.state_started.connect(_actions_finished)
		%Parent.add_child(chara)
	var end_spawn := Time.get_ticks_usec()

	var start_input := Time.get_ticks_usec()
	if not do_control:
		for action in _actions:
			Input.parse_input_event(action)
	else:
		Input.parse_input_event(end_action)

	await finished
	var end_input := Time.get_ticks_usec()
	print("Loop(%d) -- %f" % [_num, end_input - start_spawn])
	_current_file.store_csv_line([_num, end_spawn - start_spawn, end_input - start_input, end_input - start_spawn])
	_current_file.flush()

	if _num >= 2 ** iterations:
		_reset()
		phase_done.emit()
	else:
		_num *= 2
		_timer.start()


func _actions_finished(state: String) -> void:
	if state == "sprint":
		_counter += 1
		if _counter >= _num:
			finished.emit()


func _reset() -> void:
	_num = 1
	for child in %Parent.get_children():
		child.queue_free()
