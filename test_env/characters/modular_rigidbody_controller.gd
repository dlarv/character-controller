@tool
extends ModularRigidBodyController

var is_sprinting: bool = false
var jump_buffered: bool


func _ready() -> void:
	_update_fsm_param("is_sprinting", false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sprint"):
		_update_fsm_param("is_sprinting", true)
	elif event.is_action_released("sprint"):
		_update_fsm_param("is_sprinting", false)
	elif event.is_action_pressed("ui_select"):
		_update_fsm_param("jump_buffered", true)
		_timers["jump_buffer"].start()
	
