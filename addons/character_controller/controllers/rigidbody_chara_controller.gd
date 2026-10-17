@tool
extends RigidBody3D
class_name StandardRBController

signal state_started(key: StringName)
signal state_finished(key: StringName)
signal ability_granted(key: StringName)
signal grounded
signal ungrounded

const WALK_KEY: StringName = "walk"
const SPRINT_KEY: StringName = "sprint"
const JUMP_KEY: StringName = "jump"
const DASH_KEY: StringName = "dash"
const DEFAULT_CONTACTS_REPORTED := 100

@export_category("Basic Physics")
@export var grounded_damping := Vector3(5, 0, 5)
@export var ungrounded_damping := Vector3(10, 0, 10)
## How "horizontal" another physics body must be to be considered "ground."
## e.g. a value of 1.0 means ground must be perfectly horizontal.
@export_range(0, 1) var floor_normal_threshold := 0.99
## If value != -1, only consider colliders with in this layer when checking whether player is grounded.
@export var floor_collision_layer := -1
@export_range(.01, 1000) var falling_gravity_mod := 1.0
## Once velocity.y falls below this value, body is considered to be falling.
@export var falling_threshold := 0.0
## If player's velocity meets or exceeds this amount, they'll be temp immobilized after hitting ground.
## Negative values disable heavy fall
@export var heavy_fall_threshold := 50.0
## How long player will be immobilized for after hitting ground in heavy fall.
@export var heavy_fall_wait_time := 1.0:
	set(val):
		heavy_fall_wait_time = val
		if not Engine.is_editor_hint() and _heavy_fall_timer:
			_heavy_fall_timer.wait_time = val
@export_category("Basic Abilities")
@export var walk_speed := 50.0
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var move_left_action := "ui_left"
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var move_right_action := "ui_right"
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var move_up_action := "ui_up"
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var move_down_action := "ui_down"

@export_group("Sprint")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "")
var sprint_enabled := true:
	set(val):
		sprint_enabled = val
		is_sprinting = is_sprinting and val
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var sprint_action := ""
@export var sprint_speed := 100.0
## If false, player must press and hold run button to run
@export var sprint_toggle_mode := true
@export_group("Jumping")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "")
var jump_enabled := true
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var jump_action := "ui_select"
@export_range(1, 1000) var jump_height := 10.0
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

@export_group("Dash")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "")
var dash_enabled := true
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var dash_action := ""
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


# Helper vars that can be read by AnimationTree
var is_sprinting := false:
	set(val):
		is_sprinting = val
		if val: state_started.emit(SPRINT_KEY)
		else: state_finished.emit(SPRINT_KEY)
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
var is_dashing: bool:
	set(val):
		is_dashing = val
		if val: state_started.emit(DASH_KEY)
		else: state_finished.emit(DASH_KEY)
var is_heavy_fall := false
var is_on_floor := true:
	set(val):
		is_on_floor = val
		if val: grounded.emit()
		else: ungrounded.emit()
var is_jumping := false:
	set(val):
		is_jumping = val
		if val: state_started.emit(JUMP_KEY)
var can_sprint := true:
	set(val):
		can_sprint = val
		is_sprinting = false
var can_jump := true
var can_dash := true
var last_facing_direction: Vector3

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
var _dash_buffered := false
var _dash_buffer_timer: Timer
var _h_speed := Vector3.ZERO

func _enter_tree() -> void:
	# This allows apply_force() and similar methods to be called in _integrate_forces()
	can_sleep = false
	_initial_gravity_scale = gravity_scale

	if not contact_monitor:
		contact_monitor = true
		max_contacts_reported = DEFAULT_CONTACTS_REPORTED

	var _create_timer := func(time: float) -> Timer:
		var _timer := Timer.new()
		_timer.autostart = false
		_timer.one_shot = true
		if time > 0:
			_timer.wait_time = time
		return _timer

	_coyote_timer = _create_timer.call(coyote_time)
	add_child(_coyote_timer)
	_coyote_timer.timeout.connect(func(): can_jump = false)

	if  OS.is_debug_build() or variable_jump_frames > 0:
		_variable_jump_timer = _create_timer.call(float(variable_jump_frames) / Engine.physics_ticks_per_second)
		add_child(_variable_jump_timer)
	
	if OS.is_debug_build() or heavy_fall_threshold >= 0:
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

	_connect_state_signals()


func _unhandled_input(event: InputEvent) -> void:
	if sprint_enabled and can_sprint:
		_set_sprint_mode(event)
	if event.is_action_pressed(jump_action):
		_jump_buffer_timer.start()
		_jump_buffered = true
	if event.is_action_pressed(dash_action):
		_dash_buffer_timer.start()
		_dash_buffered = true


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _heavy_fall_timer and not _heavy_fall_timer.is_stopped(): return
	if is_dashing: 
		state.linear_velocity = _dash_velocity
		global_position.y = _dash_y_position
		return

	var _prev_speed := _h_speed
	_h_speed = _get_movement_vector(sprint_speed if is_sprinting else walk_speed)
	if _h_speed.length() > 0:
		last_facing_direction = _h_speed.normalized()
		if is_zero_approx(_prev_speed.length()) and not is_sprinting:
			state_started.emit(WALK_KEY)
	elif _prev_speed.length() > 0 and not is_sprinting:
		state_finished.emit(WALK_KEY)
		
	state.apply_central_force(_h_speed)
	_calculate_damping(state)

	_calculate_if_on_floor(state)

	if _try_dash(state): pass
	elif _try_jump(state): pass
	elif _try_fall(falling_gravity_mod): pass
	else:
		gravity_scale = _initial_gravity_scale
		can_jump = true
		can_dash = true
		if is_heavy_fall and _heavy_fall_timer:
			_heavy_fall_timer.start()
	
	if heavy_fall_threshold >= 0 and abs(linear_velocity.y) >= heavy_fall_threshold:
		is_heavy_fall = true
	

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
		if floor_collision_layer >= 0: 
			var _obj = state.get_contact_collider_object(i)

			if not _obj.has_method("get_collision_layer_value") \
					or not _obj.get_collision_layer_value(floor_collision_layer):
				continue

		var _normal := state.get_contact_local_normal(i)
		if _normal.dot(Vector3.UP) >= floor_normal_threshold:
			is_on_floor = true
			break


func _check_variable_jump_running(running:=true) -> bool:
	if variable_jump_frames == 0: return false
	elif running: return not _variable_jump_timer.is_stopped()
	else: return _variable_jump_timer.is_stopped()


func _calculate_damping(state: PhysicsDirectBodyState3D) -> void:
	var _tps := Engine.physics_ticks_per_second
	var _external_damp := Vector3.ONE * state.total_linear_damp
	var _internal_damp := grounded_damping if is_on_floor else ungrounded_damping
	_internal_damp += _external_damp * (1 if linear_damp_mode == DAMP_MODE_COMBINE else 0)
	state.linear_velocity.x *= 1 - _internal_damp.x / _tps
	state.linear_velocity.y *= 1 - _internal_damp.y / _tps
	state.linear_velocity.z *= 1 - _internal_damp.z / _tps


func _set_sprint_mode(event: InputEvent) -> void:
	if sprint_toggle_mode:
		if event.is_action_pressed(sprint_action):
			is_sprinting = true
		elif event.is_action_released(sprint_action):
			is_sprinting = false
	else:
		if event.is_action_pressed(sprint_action):
			is_sprinting = not is_sprinting


func _try_fall(gravity_mod: float) -> bool:
	# Don't apply heavier gravity before coyote time runs out
	if not _coyote_timer.is_stopped(): return false
	if is_on_floor: return false
	if can_jump:
		_coyote_timer.start()
		# player is falling, just not with heavier gravity
		return true
	if is_falling:
		gravity_scale = gravity_mod
	return true


func _try_jump(state: PhysicsDirectBodyState3D) -> bool:
	if jump_enabled \
			and _jump_buffered \
			and can_jump:
		if _check_variable_jump_running(false):
			_variable_jump_timer.start()
		can_jump = false
		_coyote_timer.stop()
		state.linear_velocity.y = 0
		_jump(state)
		is_jumping = true
		return true
	elif Input.is_action_pressed(jump_action) and _check_variable_jump_running(true):
		_jump(state, variable_jump_amount)
		return true
	if is_jumping:
		is_jumping = false
		state_finished.emit(JUMP_KEY)

	return false


func _jump(state: PhysicsDirectBodyState3D, velocity_modifier:=1.0) -> void:
	# 0 = v^2 + 2ax
	var _velocity := sqrt(2 * abs(state.total_gravity.y) * jump_height) * velocity_modifier
	state.apply_central_impulse(Vector3.UP * _velocity)

	_skip_next_grounded_check = true


func _try_dash(state: PhysicsDirectBodyState3D) -> bool:
	if not dash_enabled or not can_dash: return false
	if not _dash_buffered: return false

	is_dashing = true
	_dash_timer.start()
	state.linear_velocity = Vector3.ZERO

	var _direction := last_facing_direction
	var _velocity :=  dash_length / dash_time
	_dash_velocity = _velocity * _direction
	state.linear_velocity = _dash_velocity
	_dash_y_position = global_position.y

	return true


## Public method for enabling/disabling character movement abilities. 
## Enabling gives the player semi-permanent access to this ability. Use refresh_ability() to temporarily restore ability.
## Returns false if ability_name doesn't match an existing ability; can be overridden to support more abilities.
func enable_ability(key: StringName, enabled: bool) -> bool:
	match key:
		SPRINT_KEY:
			sprint_enabled = enabled
			return true
		JUMP_KEY:
			jump_enabled = enabled
			return true
		DASH_KEY:
			dash_enabled = enabled
			return true
	return false


## Used to bulk enable/disable abilities.
## Returns array of states not found.
## See enable_ability() documentation for more details.
func enable_abilities(keys: Array, enabled: bool) -> Array[StringName]:
	var remaining_keys: Array[StringName] = []
	for key in keys:
		if not enable_ability(key, enabled):
			remaining_keys.append(key)
	return remaining_keys
		

## Public method for returning character's movement abilities. 
## Refreshing temporarily returns/removes player's access to an ability. Use enable_ability() to semi-permanently enable/disable access.
## Returns false if ability_name doesn't match an existing ability; can be overridden to support more abilities.
func refresh_ability(key: StringName, refresh:=true) -> bool:
	match key:
		SPRINT_KEY:
			can_sprint = refresh
			return true
		JUMP_KEY:
			can_jump = refresh
			return true
		DASH_KEY:
			can_dash = refresh
			return true
	return false


## Used to bulk enable/disable abilities.
## Returns array of states not found.
## See refresh_ability() documentation for more details.
func refresh_abilities(keys: Array, enabled: bool) -> Array[StringName]:
	var remaining_keys: Array[StringName] = []
	for key in keys:
		if not refresh_ability(key, enabled):
			remaining_keys.append(key)
	return remaining_keys


## Called the first time player receives ability.
## Signals to any modules to disconnect signals/etc.
func grant_ability(key: StringName) -> bool:
	ability_granted.emit(key)
	return enable_ability(key, true)


func get_state_data() -> Dictionary:
	return {
		SPRINT_KEY: {
			"enabled": sprint_enabled,
			"can": can_sprint,
			"speed": sprint_speed
		},
		WALK_KEY: {
			"speed": walk_speed
		},
		DASH_KEY: {
			"enabled": dash_enabled,
			"can": can_dash,
			"length": dash_length,
			"duration": dash_time,
		},
		JUMP_KEY: {
			"enabled": jump_enabled,
			"can": can_jump,
			"height": jump_height
		}
	}


func _connect_state_signals(skip:=false) -> void:
	if skip: return
	var _debug_show_current_state := func (state_name: String, is_active: bool) -> void:
		if is_active:
			print("%s started" % state_name)
		else:
			print("%s finished" % state_name)
	state_started.connect(_debug_show_current_state.bind(true))
	state_finished.connect(_debug_show_current_state.bind(false))


