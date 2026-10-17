@abstract
extends Node
class_name ControllerActionState

@warning_ignore("unused_signal")
signal fsm_param_update_request(key: String, value: Variant)
@warning_ignore("unused_signal")
signal timer_register_request(key: String, timer: Timer, reparent: bool)
signal activated
signal deactivated


var _sub_states: Array[ControllerActionState]

func setup(_controller: Node3D) -> void: 
	_sub_states = []

	for child in get_children():
		if child is ControllerActionState:
			_sub_states.append(child)
	deactivate()


func process_update(delta: float) -> void: 
	for child in _sub_states: 
		child.process_update(delta)


func physics_update(state: PhysicsDirectBodyState3D) -> void: 
	for child in _sub_states: 
		child.physics_update(state)


# If using nested YAFSM states, override this method
func propagate_substate(_state_key: Array[String]) -> void: pass


func activate() -> void: 
	activated.emit()
	# print("Action(%s) activated" % get_path())


func deactivate() -> void: 
	deactivated.emit()
	# print("Action(%s) deactivated" % get_path())


static func _create_timer(time: float) -> Timer:
	var timer := Timer.new()
	timer.wait_time = time
	timer.one_shot = true
	timer.autostart = false
	return timer
