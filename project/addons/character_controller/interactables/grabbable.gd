@tool
@icon("uid://1qxooiure0ql")
extends Interactable
class_name Grabbable

const GRABBER_GROUP := "grabber"

var _is_grabbed := false


func _enter_tree() -> void:
	super._enter_tree()

	if not interacted.is_connected(_on_interacted):
		interacted.connect(_on_interacted)


func _ready() -> void:
	_interactor_group = GRABBER_GROUP


func _on_interacted(physics_body: Node, interactable: Interactable, interactor: Node3D) -> void:
	interactor.grab(physics_body)
