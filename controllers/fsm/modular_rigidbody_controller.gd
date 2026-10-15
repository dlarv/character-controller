@tool
extends RigidBody3D
class_name ModularRigidBodyController

@export var state_machine: StateMachine
@export var root_state: ControllerActionState = null

@onready var active_state: ControllerActionState = root_state

var state_machine_player: StateMachinePlayer
var states: Dictionary[StringName, ControllerActionState]

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return

	states = {}
	for child in get_children():
		if child is ControllerActionState:
			child.setup(self)
			states[child.name] = child
			child.fsm_param_update_request.connect(_update_fsm_param)

	state_machine_player = StateMachinePlayer.new()
	add_child(state_machine_player)
	state_machine_player.state_machine = state_machine
	state_machine_player.updated.connect(_on_state_machine_updated)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if Engine.is_editor_hint(): return
	active_state.physics_update(state)


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	active_state.process_update(delta)


func _on_state_machine_updated(key: String, _delta: float) -> void:
	var _curr_state := active_state
	var parsed_key := key.split("/")
	key = parsed_key[0]

	if states.has(key):
		_curr_state = states[key]
	
	if _curr_state != active_state:
		active_state.process_mode = Node.PROCESS_MODE_DISABLED
		_curr_state.process_mode = Node.PROCESS_MODE_INHERIT
		active_state = _curr_state
	elif len(parsed_key) > 1:
		_curr_state.propagate_substate(parsed_key.slice(1))


func _update_fsm_param(key: String, value: Variant) -> void:
	state_machine_player.set_param(key, value)
