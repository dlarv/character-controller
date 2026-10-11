@tool
@abstract
extends Resource
class_name ControllerActionState

@export var input_action: String
@export var connections: Array[ControllerActionState] = []


func setup(controller: Node3D) -> void: pass


func reset_connections() -> void:
	connections = []


func add_connection(other: ControllerActionState, transition: Transition) -> void:
	connections.append(other)
