extends Camera3D

@export var offset: Vector3
@export var targets: Array[Node3D]
@export var switch_delay := 0.5
@export var start_idx := 0
@export var god_mode_speed := 30.0

@onready var _target: Node3D = targets[start_idx] if len(targets) > 0 else null
@onready var _curr_target_idx := start_idx

var _perspective_switch_tween: Tween
var _god_mode := false


func _ready():
	for target in targets:
		target.process_mode = Node.PROCESS_MODE_DISABLED

	_next_perspective(start_idx)



func _input(event: InputEvent):
	if event.is_action_pressed("switch_perspective"):
		_next_perspective((_curr_target_idx + 1) % len(targets))
	elif event.is_action_pressed("toggle_god_mode"):
		_god_mode = not _god_mode 
		if _god_mode:
			_target.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			_target.process_mode = Node.PROCESS_MODE_INHERIT
	elif event.is_action_pressed("return_to_center"):
		_target.process_mode = Node.PROCESS_MODE_DISABLED
		_target.global_position = Vector3.ZERO
		_target.process_mode = Node.PROCESS_MODE_INHERIT
		global_position = offset


func _process(delta: float) -> void:
	if len(targets) == 0 or _target == null: return
	if _perspective_switch_tween and _perspective_switch_tween.is_running(): return
	if _god_mode:
		_move_god_mode(delta)
		return

	position = _target.position + offset

	
func _next_perspective(idx: int) -> void:
	_curr_target_idx = idx
	_target.process_mode = Node.PROCESS_MODE_DISABLED
	_target = targets[_curr_target_idx]

	_perspective_switch_tween = create_tween()
	_perspective_switch_tween.tween_property(self, "position", _target.position + offset, switch_delay)
	_perspective_switch_tween.finished.connect(func():
		_target.process_mode = Node.PROCESS_MODE_INHERIT
	)

func _move_god_mode(delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var h_direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	if h_direction:
		global_position.x += h_direction.x * god_mode_speed * delta
		global_position.z += h_direction.z * god_mode_speed * delta

	var vertical_dir := Input.get_axis("god_mode_down", "god_mode_up")
	if vertical_dir:
		global_position.y += vertical_dir * god_mode_speed * delta


	_target.position = position - offset
