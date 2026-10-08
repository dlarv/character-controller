extends RigidBody3D

@export_category("Movement Parameters")
@export_group("Horizontal Motion")
@export var walk_speed := 50.0
## Sets default linear_damp to this value. If -1, uses value inside linear_damp instead.
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
@export var can_jump := true
@export_range(1, 1000) var jump_height := 10.0
## Approx time to reach apex of jump. Loses accuracy the higher above 1.0 it gets.
@export_range(0.1, 100) var jump_up_time := 1.0
@export_range(0.1, 100) var jump_down_time := 1.0
## Once velocity.y falls below this value, body is considered to be falling.
@export var falling_threshold := 0.0

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
var is_on_floor := true
## For some reason, is_on_floor returns true for the tick right after the player jumps, despite player not
## being grounded. This seems to happen for the CharacterBody3D as well, so its not just my impl.
## This is a gross fix, hopefully I'll figure out how to solve it later.
var _skip_next_grounded_check := false
var _initial_gravity_scale: float


func _enter_tree() -> void:
	# This allows apply_force() and similar methods to be called in _integrate_forces()
	can_sleep = false
	_initial_gravity_scale = gravity_scale


func _input(event: InputEvent) -> void:
	if sprint_toggle_mode:
		if event.is_action_pressed(sprint_action):
			is_sprinting = true
		elif event.is_action_released(sprint_action):
			is_sprinting = false
	else:
		if event.is_action_pressed(sprint_action):
			is_sprinting = not is_sprinting


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var _walk_speed := _get_movement_vector(sprint_speed if is_sprinting else walk_speed)
	state.apply_central_force(_walk_speed)
	_calculate_damping(state)

	_check_if_on_floor(state)

	if can_jump and is_on_floor and Input.is_action_pressed(jump_action):
		_jump(state)
	elif not is_on_floor:
		var _gravity: float = abs(state.total_gravity.y)
		var _velocity := state.linear_velocity.y
		if _velocity < falling_threshold:
			gravity_scale = 2 * jump_height / pow(jump_down_time, 2) / _gravity
	else:
		gravity_scale = _initial_gravity_scale


func _get_movement_vector(speed: float) -> Vector3:
	var _input_dir := Input.get_vector(move_left_action, move_right_action, move_up_action, move_down_action)
	var _direction := Vector3(_input_dir.x, 0, _input_dir.y).normalized()
	return _direction * speed


## Checks if player is standing on horizontal surface.
func _check_if_on_floor(state: PhysicsDirectBodyState3D) -> void:
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


func _calculate_damping(state: PhysicsDirectBodyState3D) -> void:
	var _damp := state.total_linear_damp if linear_damp_mode == DAMP_MODE_COMBINE else 0.0

	var _h_damp := 1 - (horizontal_damping + _damp) / Engine.physics_ticks_per_second
	state.linear_velocity.x *= _h_damp
	state.linear_velocity.z *= _h_damp

	var _v_damp := 1 - (vertical_damping + _damp) / Engine.physics_ticks_per_second
	state.linear_velocity *= _v_damp


func _jump(state: PhysicsDirectBodyState3D) -> void:
	# d = vt/2
	var _velocity := 2 * jump_height / jump_up_time
	# d = vt + att/2
	var _acceleration := pow(_velocity, 2) / (2 * jump_height)
	gravity_scale = _acceleration / abs(state.total_gravity.y)

	state.apply_central_impulse(Vector3.UP * _velocity)

	_skip_next_grounded_check = true
