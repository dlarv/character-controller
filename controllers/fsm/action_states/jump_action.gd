extends ControllerActionState

@export var jump_height := 5.0
@export var jump_buffer_time := 0.1
@export var coyote_time := 0.1

var curr_substate: String

var _jump_buffered: bool:
	set(val):
		_state_machine_player.set_param("jump_buffered", val)
	get:
		return _state_machine_player.get_param("jump_buffered", false)
var _is_on_floor: bool:
	get:
		return _state_machine_player.get_param("is_on_floor", false)

var can_jump := true

var _state_machine_player: StateMachinePlayer

func setup(controller: Node3D) -> void:
	super.setup(controller)
	_state_machine_player = controller.state_machine_player

	var buffer_timer: Timer = _create_timer(jump_buffer_time)
	buffer_timer.timeout.connect(func():
		_jump_buffered = false
	)
	timer_register_request.emit("jump_buffer", buffer_timer, true)

	var coyote_timer: Timer = _create_timer(coyote_time)
	coyote_timer.timeout.connect(func():
		_state_machine_player.set_trigger("coyote_timeout")
	)
	timer_register_request.emit("coyote", coyote_timer, true)


func activate() -> void:
	super.activate()
	can_jump = true


func physics_update(state: PhysicsDirectBodyState3D) -> void: 
	if _jump_buffered and can_jump:
		can_jump = false
		state.linear_velocity.y = 0
		_jump(state)
	elif _is_on_floor:
		can_jump = true

	super.physics_update(state)


func _jump(state: PhysicsDirectBodyState3D, velocity_modifier:=1.0) -> void:
	# 0 = v^2 + 2ax
	var _velocity := sqrt(2 * abs(state.total_gravity.y) * jump_height) * velocity_modifier
	state.apply_central_impulse(Vector3.UP * _velocity)

	# _skip_next_grounded_check = true
