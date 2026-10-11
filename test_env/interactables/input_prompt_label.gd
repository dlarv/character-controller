extends Label3D

@export var interactable: Interactable
@export var prompt: String
@export var idx: int

func _ready() -> void:
	var actions := InputMap.action_get_events(interactable.input_action)
	var action_text: String
	if idx < len(actions):
		action_text = actions[idx].as_text()
	else:
		action_text = actions[0].as_text()

	text = "Press %s to %s" % [action_text, prompt]
	hide()

	if not interactable: return
	if not interactable.interactor_entered.is_connected(_on_button_interactor_entered):
		interactable.interactor_entered.connect(_on_button_interactor_entered)
	if not interactable.interactor_exited.is_connected(_on_button_interactor_exited):
		interactable.interactor_exited.connect(_on_button_interactor_exited)


func _on_button_interactor_exited(_interactor: Node3D) -> void:
	hide()


func _on_button_interactor_entered(_interactor: Node3D) -> void:
	show()

