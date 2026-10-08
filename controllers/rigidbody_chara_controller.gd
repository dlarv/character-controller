extends RigidBody3D

@export_category("Movement Parameters")
@export_group("Walking")
@export var walk_speed := 50.0
## Sets default linear_damp to this value. If -1, uses value inside linear_damp instead.
@export var walk_damp := -1.0
@export_group("Sprinting")
@export var sprint_speed := 100.0
@export_subgroup("Sprint Damping")
## Sets linear_damp while player is running. If -1, uses default value instead.
@export var sprint_damp := -1.0
## If player is currently sprinting and hits button to stop, how quickly to switch from sprint_damp to walk_damp
@export var sprint_damp_falloff := 3.0
## If false, player must press and hold run button to run
@export_subgroup("")
@export var sprint_toggle_mode := true
@export_group("Vertical Motion")
## How "horizontal" another physics body must be to be considered "ground."
## e.g. a value of 1.0 means ground must be perfectly horizontal.
@export_range(0, 1) var floor_normal_threshold := 0.99
## If value != -1, only consider colliders with in this layer when checking whether player is grounded.
@export var floor_collision_layer := -1
@export var falling_damp := 0.0
@export var falling_gravity_mod := 10.0
@export_subgroup("Jumping")
@export var jump_height := 10.0
## Approx time to reach apex of jump. Loses accuracy the higher above 1.0 it gets.
@export var jump_up_time := 1.0
@export var jump_hang_time := 0.5
@export var jump_down_time := 1.0

@export_category("Input Action Labels")
@export var move_left_action := "ui_left"
@export var move_right_action := "ui_right"
@export var move_up_action := "ui_up"
@export var move_down_action := "ui_down"
@export var sprint_action := ""
@export var jump_action := "ui_select"

# @onready var jump_initial_velocity := (jump_height / jump_up_time) + (9.8 * jump_up_time) / 2
# @onready var jump_initial_velocity := sqrt(2 * 9.8 * jump_height)
@warning_ignore_start("unused_private_class_variable")
var _gravity_tween: Tween
# Helper vars that can be read by AnimationTree
var _is_sprinting := false:
	set(val):
		_is_sprinting = val
		_set_damping_mode()
var _is_moving_horizontal: bool:
	get:
		return abs(linear_velocity.x) > 0 or abs(linear_velocity.z) > 0
var _is_moving_vertical: bool:
	get:
		return abs(linear_velocity.y) > 0
var _is_walking: bool:
	get:
		return  _is_moving_horizontal and not _is_sprinting
var _is_on_floor := true
## For some reason, _is_on_floor returns true for the tick right after the player jumps, despite player not
## being grounded. This seems to happen for the CharacterBody3D as well, so its not just my impl.
## This is a gross fix, hopefully I'll figure out how to solve it later.
var _skip_next_grounded_check := false


func _enter_tree() -> void:
	# This allows apply_force() and similar methods to be called in _integrate_forces()
	can_sleep = false

	if walk_damp < 0:
		walk_damp = linear_damp
	else:
		linear_damp = walk_damp

	if sprint_damp < 0:
		sprint_damp = walk_damp


func _input(event: InputEvent) -> void:
	if sprint_toggle_mode:
		if event.is_action_pressed(sprint_action):
			_is_sprinting = true
		elif event.is_action_released(sprint_action):
			_is_sprinting = false
	else:
		if event.is_action_pressed(sprint_action):
			_is_sprinting = not _is_sprinting


var _height := []
var tick := -1
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var vel := _get_movement_vector(sprint_speed if _is_sprinting else walk_speed)
	state.apply_central_force(vel)

	_check_if_on_floor(state)

	tick += 1

	var velocity := state.linear_velocity.y
	if _is_on_floor and Input.is_action_just_pressed(jump_action):
		velocity =_get_jump_initial_velocity()
		_set_jump_acceleration(velocity)
		state.apply_central_impulse(Vector3.UP * velocity)

		_skip_next_grounded_check = true

		# print("a = %.2f" % gravity_scale)
		_height = []
		print("Tick %f - JUMP" % tick)
		# print("vel = %.2f / %.2f = %.2f" % [velocity, state.linear_velocity.y, velocity / state.linear_velocity.y])
	elif not _is_on_floor:
		print("Tick %f" % tick)
		if velocity < 0:
			gravity_scale = falling_gravity_mod
			pass
	else:
		print("Tick %f - GROUNDED" % tick)
		gravity_scale = 1

	if not _is_on_floor:
		_height.append(position.y)
	elif len(_height) > 0:
		print("h = %.2f" % _height.max())
		_height = []


func _get_movement_vector(speed: float) -> Vector3:
	var inputDir := Input.get_vector(move_left_action, move_right_action, move_up_action, move_down_action)
	var direction := Vector3(inputDir.x, 0, inputDir.y).normalized()
	return direction * speed


func _set_damping_mode() -> void:
	if not _is_on_floor:
		linear_damp = falling_damp
	elif _is_sprinting:
		linear_damp = sprint_damp
	elif _is_moving_horizontal and sprint_damp > 0:
		var tween := create_tween()
		tween.tween_property(self, "linear_damp", walk_damp, sprint_damp_falloff)
	else:
		linear_damp = walk_damp


## Checks if player is standing on horizontal surface.
## Sets _is_on_floor helper variable and calls _set_damping_mode
func _check_if_on_floor(state: PhysicsDirectBodyState3D) -> void:
	if _skip_next_grounded_check:
		_is_on_floor = false
		_skip_next_grounded_check = false
		return

	_is_on_floor = false
	for i in state.get_contact_count():
		if floor_collision_layer > 0: 
			var obj = state.get_contact_collider_object(i)

			if not obj.has_method("get_collision_layer_value") \
					or not obj.get_collision_layer_value(floor_collision_layer):
				continue

		var normal := state.get_contact_local_normal(i)
		if normal.dot(Vector3.UP) >= floor_normal_threshold:
			_is_on_floor = true
			break
	#_set_damping_mode()


func _get_jump_initial_velocity() -> float:
	# return jump_height / jump_up_time + 4.9 * jump_up_time
	return 2 * jump_height / jump_up_time


func _set_jump_acceleration(velocity: float) -> void:
	gravity_scale = pow(velocity, 2) / (2 * jump_height) / 9.8
