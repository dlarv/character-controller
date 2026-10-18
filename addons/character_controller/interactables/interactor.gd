@tool
extends Area3D
class_name Interactor

enum OccupiedMode { FREE, JEALOUS, NON_JEALOUS }

@export var root: Node = null

var occupied_mode := OccupiedMode.FREE


func _ready() -> void:
	add_to_group(Interactable.BASE_INTERACTOR_GROUP)

	if root == null:
		root = get_parent()


func interact_with(interactable: Interactable) -> void:
	if interactable == null:
		occupied_mode = OccupiedMode.FREE
		_flicker_collider()
	elif interactable.jealous:
		occupied_mode = OccupiedMode.JEALOUS
	else:
		occupied_mode = OccupiedMode.NON_JEALOUS


func _flicker_collider() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(0.05).timeout
	process_mode = Node.PROCESS_MODE_INHERIT
