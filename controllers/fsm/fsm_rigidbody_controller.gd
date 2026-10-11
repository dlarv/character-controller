@tool
extends RigidBody3D

@export var states: Dictionary[String, ControllerActionState]
@export var state_machine: StateMachine
@export var root_state: ControllerActionState = null

@onready var active_state: ControllerActionState = root_state
var state_machine_player: StateMachinePlayer


func _enter_tree() -> void:
	if Engine.is_editor_hint(): return

	for state in states.values():
		state.setup(self)

	state_machine_player = StateMachinePlayer.new()
	add_child(state_machine_player)
	state_machine_player.state_machine = state_machine
	state_machine_player.updated.connect(_on_state_machine_updated)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	pass


func _on_state_machine_updated(state: String, _delta: float) -> void:
	pass

## Uses a StateMachine to define the structure of a graph
@warning_ignore("shadowed_variable")
static func _convert_state_machine_to_graph(states: Dictionary[String, ControllerActionState], state_machine: StateMachine) -> ControllerActionState:
	@warning_ignore("shadowed_variable")
	var root_state: ControllerActionState
	var transitions: Dictionary[String, Dictionary] = state_machine.transitions

	# start_name  matches both the name of state in StateMachine as well as self.states
	for start_name in transitions:
		if start_name == "Entry":
			# Ignores any other connections Entry state might have
			var entry: Array[String] = transitions[start_name].keys()
			if len(entry) == 0:
				push_error("StateMachine(%s) Entry node has no connections!" % state_machine.resource_name)
			elif len(entry) > 1:
				push_warning("StateMachine(%s) Entry node has multiple connections! Only first one will be used"  % state_machine.resource_name)
			else:
				root_state = states[entry[0]]
			continue

		var curr_state: ControllerActionState = states[start_name]
		curr_state.reset_connections()
		var connections: Dictionary[String, Transition] = transitions[start_name]

		# end_name also matches both the name of state in StateMachine as well as self.states
		for end_name in connections:
			var next_state: ControllerActionState = states[end_name]
			curr_state.add_connection(next_state, connections[end_name])

	return root_state
