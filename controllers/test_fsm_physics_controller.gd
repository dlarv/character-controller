extends RigidBody3D

var NULL_CALLABLE := func(): return true

@export var state_machine: StateMachine

@export_category("Movement Parameters")
@export_group("Horizontal Motion")
@export var walk_speed := 50.0
@export var sprint_enabled := true
@export var sprint_speed := 100.0
## If false, player must press and hold run button to run
@export var sprint_toggle_mode := true
@export var horizontal_damping := 5.0
@export_group("Vertical Motion")
## How "horizontal" another physics body must be to be considered "ground."
## e.g. a value of 1.0 means ground must be perfectly horizontal.
@export_range(0, 1) var floor_normal_threshold := 0.99
## If value != -1, only consider colliders with in this layer when checking whether player is grounded.
@export var floor_collision_layer := -1
@export var vertical_damping := 0.0
## If player's velocity meets or exceeds this amount, they'll be temp immobilized after hitting ground.
@export var heavy_fall_threshold := 50.0
## How long player will be immobilized for after hitting ground in heavy fall.
@export var heavy_fall_wait_time := 1.0:
	set(val):
		heavy_fall_wait_time = val
		if not Engine.is_editor_hint() and _heavy_fall_timer:
			_heavy_fall_timer.wait_time = val
@export_subgroup("Jumping")
@export var jump_enabled := true
@export_range(1, 1000) var jump_height := 10.0
## Once velocity.y falls below this value, body is considered to be falling.
@export var falling_threshold := 0.0
@export_range(.01, 1000) var falling_gravity_mod := 1.0
@export var coyote_time := 0.1:
	set(val):
		coyote_time = val
		if not Engine.is_editor_hint() and _coyote_timer:
			_coyote_timer.wait_time = val
## The number of frames after pressing jump button where holding button will increase jump velocity.
@export var variable_jump_frames:= 0:
	set(val):
		variable_jump_frames = val
		if not Engine.is_editor_hint() and _variable_jump_timer:
			_variable_jump_timer.wait_time = float(val) / Engine.physics_ticks_per_second

## Modifies how much extra velocity is added per frame of variable jump
@export var variable_jump_amount := 0.3
## How long to keep jump buffer for
@export var jump_buffer_time := 0.1:
	set(val):
		jump_buffer_time = val
		if not Engine.is_editor_hint() and _jump_buffer_timer:
			_jump_buffer_timer.wait_time = val

@export_category("Dash")
@export var dash_enabled := true
@export var dash_length := 3.0
@export var dash_time := 1.0:
	set(val):
		dash_time = val
		if not Engine.is_editor_hint() and _dash_timer:
			_dash_timer.wait_time = val
@export var dash_buffer_time := 0.1:
	set(val):
		dash_buffer_time = val
		if not Engine.is_editor_hint() and _dash_buffer_timer:
			_dash_buffer_timer.wait_time = val

@export_category("Input Action Labels")
@export var move_left_action := "ui_left"
@export var move_right_action := "ui_right"
@export var move_up_action := "ui_up"
@export var move_down_action := "ui_down"
@export var sprint_action := ""
@export var jump_action := "ui_select"
@export var dash_action := ""

# Helper vars that can be read by AnimationTree
var is_sprinting := false
var is_moving_horizontal: bool:
	get:
		return abs(linear_velocity.x) > 0 or abs(linear_velocity.z) > 0
var is_moving_vertical: bool:
	get:
		return abs(linear_velocity.y) > 0
var is_walking: bool:
	get:
		return  is_moving_horizontal and not is_sprinting
var is_falling: bool:
	get:
		return linear_velocity.y < falling_threshold
var is_dashing: bool
var is_heavy_fall := false:
	set(val):
		is_heavy_fall = val
		if not Engine.is_editor_hint() and state_machine_player:
			state_machine_player.set_param("heavy_fall", val)

var is_on_floor := true
var can_jump := true
var can_dash := true
var state_machine_player: StateMachinePlayer


## For some reason, is_on_floor returns true for the tick right after the player jumps, despite player not
## being grounded. This seems to happen for the CharacterBody3D as well, so its not just my impl.
## This is a gross fix, hopefully I'll figure out how to solve it later.
var _skip_next_grounded_check := false
var _initial_gravity_scale: float
var _coyote_timer: Timer
var _variable_jump_timer: Timer = null
var _heavy_fall_timer: Timer = null
var _jump_buffered := false
var _jump_buffer_timer: Timer
var _dash_velocity: Vector3
var _dash_y_position: float
var _dash_timer: Timer
var _last_facing_direction: Vector3
var _dash_buffered := false
var _dash_buffer_timer: Timer
var _active_states := NULL_CALLABLE


func _enter_tree() -> void:
	state_machine_player = StateMachinePlayer.new()
	add_child(state_machine_player)
	state_machine_player.state_machine = state_machine
	state_machine_player.updated.connect(_on_state_machine_updated)

	# This allows apply_force() and similar methods to be called in _integrate_forces()
	can_sleep = false

	_initial_gravity_scale = gravity_scale

	var _create_timer := func(time: float) -> Timer:
		var _timer := Timer.new()
		_timer.autostart = false
		_timer.one_shot = true
		_timer.wait_time = time
		return _timer

	_coyote_timer = _create_timer.call(coyote_time)
	add_child(_coyote_timer)
	_coyote_timer.timeout.connect(func(): 
		if not is_on_floor:
			can_jump = false
	)

	if variable_jump_frames > 0:
		_variable_jump_timer = _create_timer.call(float(variable_jump_frames) / Engine.physics_ticks_per_second)
		add_child(_variable_jump_timer)
	
	if heavy_fall_threshold > 0:
		_heavy_fall_timer = _create_timer.call(heavy_fall_wait_time)
		add_child(_heavy_fall_timer)
		_heavy_fall_timer.timeout.connect(func(): is_heavy_fall = false)
	
	_jump_buffer_timer = _create_timer.call(jump_buffer_time)
	add_child(_jump_buffer_timer)
	_jump_buffer_timer.timeout.connect(func(): _jump_buffered = false)

	_dash_timer = _create_timer.call(dash_time)
	add_child(_dash_timer)
	_dash_timer.timeout.connect(func(): is_dashing = false)

	_dash_buffer_timer = _create_timer.call(dash_buffer_time)
	add_child(_dash_buffer_timer)
	_dash_buffer_timer.timeout.connect(func(): _dash_buffered = false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(jump_action):
		_jump_buffer_timer.start()
		_jump_buffered = true
		state_machine_player.set_param("jump_buffered", _jump_buffered and can_jump)
	if event.is_action_pressed(dash_action):
		_dash_buffer_timer.start()
		_dash_buffered = true
		state_machine_player.set_param("dash_buffered", _dash_buffered and can_dash)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_calculate_if_on_floor(state)

	if _active_states != NULL_CALLABLE and not _active_states.call(state):
		return

	var _walk_speed := _get_movement_vector(sprint_speed if is_sprinting else walk_speed)
	if _walk_speed.length() > 0:
		_last_facing_direction = _walk_speed.normalized()
	state.apply_central_force(_walk_speed)
	state_machine_player.set_param("h_speed", _walk_speed.length())

	_calculate_damping(state)

	state_machine_player.set_param("v_speed", state.linear_velocity.y)


func _on_state_machine_updated(state: String, _delta: float) -> void:
	match state:
		"idle","walk","rising":
			_active_states = NULL_CALLABLE
		"jump":
			_active_states = jump
		"falling", "heavy_fall":
			_active_states = fall
		"landed":
			# Doesn't work if not grounded and can't really call _calculate_if_on_floor() from here
			# But this state is only reachable when player is @falling and their velocity.y == 0
			is_on_floor = true
			fall()
		"dash":
			pass


func jump(state: PhysicsDirectBodyState3D, velocity_modifier:=1.0) -> bool:
	can_jump = false
	_coyote_timer.stop()
	state.linear_velocity.y = 0
	state_machine_player.set_param("jump_buffered", false)

	# 0 = v^2 + 2ax
	var _velocity := sqrt(2 * abs(state.total_gravity.y) * jump_height) * velocity_modifier
	state.apply_central_impulse(Vector3.UP * _velocity)

	_skip_next_grounded_check = true
	return true


func fall(_state: PhysicsDirectBodyState3D=null) -> bool:
	if abs(linear_velocity.y) >= heavy_fall_threshold:
		is_heavy_fall = true

	# Player has just landed
	if is_on_floor:
		if not _heavy_fall_timer.is_stopped():
			return false

		gravity_scale = _initial_gravity_scale
		can_jump = true
		state_machine_player.set_param("jump_buffered", _jump_buffered and can_jump)

		can_dash = true
		return true

	# Player stepped off ledge or is midair for similar reason
	if can_jump:
		_coyote_timer.start()
		return true

	# Don't apply heavier gravity before coyote time runs out
	if _coyote_timer.is_stopped() and is_falling:
		gravity_scale = falling_gravity_mod
	
	return true


func _get_movement_vector(speed: float) -> Vector3:
	var _input_dir := Input.get_vector(move_left_action, move_right_action, move_up_action, move_down_action)
	var _direction := Vector3(_input_dir.x, 0, _input_dir.y).normalized()
	return _direction * speed


func _calculate_damping(state: PhysicsDirectBodyState3D) -> void:
	var _damp := state.total_linear_damp if linear_damp_mode == DAMP_MODE_COMBINE else 0.0

	var _h_damp := 1 - (horizontal_damping + _damp) / Engine.physics_ticks_per_second
	state.linear_velocity.x *= _h_damp
	state.linear_velocity.z *= _h_damp

	var _v_damp := 1 - (vertical_damping + _damp) / Engine.physics_ticks_per_second
	state.linear_velocity *= _v_damp


## Checks if player is standing on horizontal surface.
func _calculate_if_on_floor(state: PhysicsDirectBodyState3D) -> void:
	if _skip_next_grounded_check:
		is_on_floor = false
		_skip_next_grounded_check = false
		return

	is_on_floor = false
	for i in state.get_contact_count():
		if floor_collision_layer > 0: 
			var _obj = state.get_contact_collider_object(i)

			if not _obj.has_method("get_collision_layer_value") \
					or not _obj.get_collision_layer_value(floor_collision_layer):
				continue

		var _normal := state.get_contact_local_normal(i)
		if _normal.dot(Vector3.UP) >= floor_normal_threshold:
			is_on_floor = true
			break
