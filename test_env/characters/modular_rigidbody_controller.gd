@tool
extends ModularRigidBodyController


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sprint"):
		_update_fsm_param("is_sprinting", true)
	elif event.is_action_released("sprint"):
		_update_fsm_param("is_sprinting", false)
	elif event.is_action_pressed("ui_select"):
		_update_fsm_param("jump_buffered", true)
	
