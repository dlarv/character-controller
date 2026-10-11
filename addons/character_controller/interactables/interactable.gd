@icon("uid://m3m847qoxpd0")
extends Area3D
class_name Interactable

# Player leaving range of one Jealous interactable should allow other in-range interactables to potentially show prompt
# Support for multiple interactors?

signal interacted(package: Node, interactable: Interactable, interactor: Node3D)
signal interactor_entered(interactor: Node3D)
signal interactor_exited(interactor: Node3D)

const OccupiedMode := Interactor.OccupiedMode
const BASE_INTERACTOR_GROUP := "interactor"

@export var input_action := "ui_select"
## An object passed to anything listening to the interacted signal.
## Defaults to this object parent or self, if it has none.
@export var target: Node = null
## If true, player can only interact with this if they are not also in range of any other interactables.
@export var jealous := true
## If true, iteractable will set input as handled.
@export var consume_input := true

var _interactor: Node3D
var _label: Label3D
var _interactor_group := ""

func _enter_tree() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	if target == null:
		target = get_parent()
		if target == null:
			target = self
	
	if _interactor_group == "":
		_interactor_group = BASE_INTERACTOR_GROUP


func _unhandled_input(event: InputEvent) -> void:
	if _interactor == null: return
	if event.is_action_pressed(input_action):
		interacted.emit(target, self, _interactor)
		if consume_input:
			get_viewport().set_input_as_handled()


func _on_area_entered(body: Node3D) -> void:
	if not _check_interactor(body): return
	_interactor = body
	interactor_entered.emit(body)
	body.interact_with(self)


func _on_area_exited(body: Node3D) -> void:
	if body != _interactor: return
	_interactor = null
	interactor_exited.emit(body)
	body.interact_with(null)


func _check_interactor(node: Node3D) -> bool:
	if not node is Interactor or not node.is_in_group(_interactor_group): return false
	# Jealous and non-jealous interactables. Assume body is in range of both at once.
	# Jealous -> Jealous			only first shows prompt
	# non-jealous -> Jealous		only first shows prompt
	if jealous and not node.occupied_mode == OccupiedMode.FREE: return false
	# Jealous -> non-jealous		only first shows prompt
	elif node.occupied_mode == OccupiedMode.JEALOUS: return false
	# non-jealous -> non-jealous	both show prompt
	return true
