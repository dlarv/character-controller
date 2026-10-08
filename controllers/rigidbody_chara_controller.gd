extends RigidBody3D

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
@export_subgroup("Jumping")
@export var jump_enabled := true
@export_range(1, 1000) var jump_height := 10.0
## Approx time to reach apex of jump. Loses accuracy the higher above 1.0 it gets.
@export_range(0.1, 100) var jump_up_time := 1.0
@export_range(0.1, 100) var jump_down_time := 1.0
## Once velocity.y falls below this value, body is considered to be falling.
@export var falling_threshold := 0.0
@export var coyote_time := 0.1
## The number of frames after pressing jump button where holding button will increase jump velocity.
@export var variable_jump_frames:= 0
## Modifies how much extra velocity is added per frame of variable jump
@export var variable_jump_amount := 0.3

@export_category("Input Action Labels")
@export var move_left_action := "ui_left"
@export var move_right_action := "ui_right"
@export var move_up_action := "ui_up"
@export var move_down_action := "ui_down"
@export var sprint_action := ""
@export var jump_action := "ui_select"

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
var is_on_floor := true
var can_jump := true

## For some reason, is_on_floor returns true for the tick right after the player jumps, despite player not
## being grounded. This seems to happen for the CharacterBody3D as well, so its not just my impl.
## This is a gross fix, hopefully I'll figure out how to solve it later.
var _skip_next_grounded_check := false
var _initial_gravity_scale: float
var _coyote_timer: Timer
var _variable_jump_timer: Timer = null


func _enter_tree() -> void:
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
	_coyote_timer.timeout.connect(func(): can_jump = false)

	if variable_jump_frames > 0:
		_variable_jump_timer = _create_timer.call(float(variable_jump_frames) / Engine.physics_ticks_per_second)
		add_child(_variable_jump_timer)


func _input(event: InputEvent) -> void:
	if sprint_enabled:
		_set_sprint_mode(event)


var height := 0.0
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var _walk_speed := _get_movement_vector(sprint_speed if is_sprinting else walk_speed)
	state.apply_central_force(_walk_speed)
	_calculate_damping(state)

	_calculate_if_on_floor(state)

	if _try_jump(state): pass
	elif _try_fall(abs(state.total_gravity.y)): pass
	else:
		gravity_scale = _initial_gravity_scale
		can_jump = true
	
	if is_on_floor and height > 0:
		print(height)
		height = 0


func _get_movement_vector(speed: float) -> Vector3:
	var _input_dir := Input.get_vector(move_left_action, move_right_action, move_up_action, move_down_action)
	var _direction := Vector3(_input_dir.x, 0, _input_dir.y).normalized()
	return _direction * speed


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


func _check_variable_jump_running(running:=true) -> bool:
	if not _variable_jump_timer: return false
	elif running: return not _variable_jump_timer.is_stopped()
	else: return _variable_jump_timer.is_stopped()


func _calculate_damping(state: PhysicsDirectBodyState3D) -> void:
	var _damp := state.total_linear_damp if linear_damp_mode == DAMP_MODE_COMBINE else 0.0

	var _h_damp := 1 - (horizontal_damping + _damp) / Engine.physics_ticks_per_second
	state.linear_velocity.x *= _h_damp
	state.linear_velocity.z *= _h_damp

	var _v_damp := 1 - (vertical_damping + _damp) / Engine.physics_ticks_per_second
	state.linear_velocity *= _v_damp


func _set_sprint_mode(event: InputEvent) -> void:
	if sprint_toggle_mode:
		if event.is_action_pressed(sprint_action):
			is_sprinting = true
		elif event.is_action_released(sprint_action):
			is_sprinting = false
	else:
		if event.is_action_pressed(sprint_action):
			is_sprinting = not is_sprinting


func _try_fall(gravity: float) -> bool:
	# Don't apply heavier gravity before coyote time runs out
	if not _coyote_timer.is_stopped(): return false
	if not is_on_floor: return false
	if can_jump:
		_coyote_timer.start()
		# player is falling, just not with heavier gravity
		return true
	height = max(height, position.y)
	if is_falling:
		gravity_scale = 2 * jump_height / pow(jump_down_time, 2) / gravity
	return true


func _try_jump(state: PhysicsDirectBodyState3D) -> bool:
	if jump_enabled \
			and Input.is_action_pressed(jump_action) \
			and can_jump:
		if _check_variable_jump_running(false):
			_variable_jump_timer.start()
		can_jump = false
		_coyote_timer.stop()
		state.linear_velocity.y = 0
		_jump(state)
		return true
	elif Input.is_action_pressed(jump_action) and _check_variable_jump_running(true):
		_jump(state, variable_jump_amount, false)
		return true
	return false

func _jump(state: PhysicsDirectBodyState3D, velocity_modifier:=1.0, adjust_gravity:=true) -> void:
	# d = vt/2
	var _velocity := 2 * jump_height / jump_up_time * velocity_modifier
	if adjust_gravity:
		# d = vt + att/2
		var _acceleration := pow(_velocity, 2) / (2 * jump_height)
		gravity_scale = _acceleration / abs(state.total_gravity.y)
	state.apply_central_impulse(Vector3.UP * _velocity)

	_skip_next_grounded_check = true
