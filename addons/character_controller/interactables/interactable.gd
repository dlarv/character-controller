@icon("res://assets/hand-tap-svgrepo-com.svg")
extends Area3D
class_name Interactable

signal interacted(package: Node, interactable: Interactable, interactor: Node3D)
signal interactor_entered(interactor: Node3D)
signal interactor_exited(interactor: Node3D)

const INTERACTOR_GROUP := "interactor"

@export var input_action := "ui_select"
## An object passed to anything listening to the interacted signal.
## Defaults to this object parent or self, if it has none.
@export var target: Node = null

var _interactor: Node3D
var _label: Label3D


func _enter_tree() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if target == null:
		target = get_parent()
		if target == null:
			target = self


func _unhandled_input(event: InputEvent) -> void:
	if _interactor == null: return
	if event.is_action_pressed(input_action):
		interacted.emit(target, self, _interactor)
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group(INTERACTOR_GROUP): return
	_interactor = body
	interactor_entered.emit(body)


func _on_body_exited(body: Node3D) -> void:
	if body != _interactor: return
	_interactor = null
	interactor_exited.emit(body)
