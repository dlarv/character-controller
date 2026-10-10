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


func _on_button_interactor_exited(_interactor: Node3D) -> void:
	hide()


func _on_button_interactor_entered(_interactor: Node3D) -> void:
	show()

