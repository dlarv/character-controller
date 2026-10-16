@tool
extends RigidBody3D
class_name ModularRigidBodyController


@export_category("State Machine")
@export var state_machine: StateMachine
@export var root_state: ControllerActionState = null
## If substate.name begins with an alphanumeric char followed by this char, treat it as special.
## Be careful, not every special char works with StateMachinePlayer.
## See _parse_substate() for more details.
@export var substate_special_char := "$"
@export var state_machine_player: StateMachinePlayer

@export_category("Universal Physics")
@export var damping := Vector3.ZERO
@export var heavy_fall_threshold := 30.0
@export var falling_gravity_mod := 1.2
## How "horizontal" another physics body must be to be considered "ground."
## e.g. a value of 1.0 means ground must be perfectly horizontal.
@export_range(0, 1) var floor_normal_threshold := 0.99
## If value != -1, only consider colliders with in this layer when checking whether player is grounded.
@export var floor_collision_layer := -1

@onready var active_state: ControllerActionState = root_state

var states: Dictionary[StringName, ControllerActionState]
var is_on_floor := true

var _timers: Dictionary[String, Timer] = {}

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return

	if not state_machine_player:
		state_machine_player = StateMachinePlayer.new()
		add_child(state_machine_player)
		state_machine_player.state_machine = state_machine
	if not state_machine_player.updated.is_connected(_on_state_machine_updated):
		state_machine_player.updated.connect(_on_state_machine_updated)

	states = {}
	for child in get_children():
		if child is ControllerActionState:
			child.timer_register_request.connect(_register_timer)
			child.setup(self)
			states[child.name] = child
			child.fsm_param_update_request.connect(_update_fsm_param)



func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Engine.is_editor_hint(): return
	active_state.physics_update(state)

	_calculate_damping(state)
	_calculate_if_on_floor(state)

	state_machine_player.set_param("v_speed", state.linear_velocity.y)
	state_machine_player.set_param(
		"h_speed", 
		abs(Vector3(state.linear_velocity.x, 0, state.linear_velocity.z).length())
	)
	state_machine_player.set_param("is_on_floor", is_on_floor)



func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	active_state.process_update(delta)


func _on_state_machine_updated(key: String, _delta:=0.0) -> void:
	print(key)
	var _curr_state := active_state
	var parsed_key := key.split("/")
	key = parsed_key[0]

	if states.has(key):
		_curr_state = states[key]
	
	if _curr_state != active_state:
		active_state.deactivate()
		_curr_state.activate()
		active_state = _curr_state
	elif len(parsed_key) > 1:
		_parse_substate(parsed_key.slice(1))


## 't$', starts a timer
## 'T$', stops a timer
## 'r$', treat substate like root level state
## (where '$' is substate_special_char)
## Otherwise, propagates it down to active_state
func _parse_substate(substates: Array[String]) -> void:
	var key := substates[0]
	if _timers.has(key):
		if key.begins_with("t" + substate_special_char):
			_timers[key.substr(2)].start()
		elif key.begins_with("T" + substate_special_char):
			_timers[key.substr(2)].stop()
	elif key.begins_with("r" + substate_special_char):
		_on_state_machine_updated(key.substr(2))
	else:
		active_state.propagate_substate(substates)


func _update_fsm_param(key: String, value: Variant) -> void:
	state_machine_player.set_param(key, value)


func _register_timer(key: String, timer: Timer, reparent_timer: bool) -> void:
	if reparent_timer:
		add_child(timer)
	_timers[key] = timer


func _calculate_damping(state: PhysicsDirectBodyState3D) -> void:
	var _damp := state.total_linear_damp if linear_damp_mode == RigidBody3D.DAMP_MODE_COMBINE else 0.0
	state.linear_velocity.x *= 1 - (damping.x + _damp) / Engine.physics_ticks_per_second
	state.linear_velocity.y *= 1 - (damping.y + _damp) / Engine.physics_ticks_per_second
	state.linear_velocity.z *= 1 - (damping.z + _damp) / Engine.physics_ticks_per_second


## Checks if player is standing on horizontal surface.
func _calculate_if_on_floor(state: PhysicsDirectBodyState3D) -> void:
	# if _skip_next_grounded_check:
	# 	is_on_floor = false
	# 	_skip_next_grounded_check = false
	# 	return

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
