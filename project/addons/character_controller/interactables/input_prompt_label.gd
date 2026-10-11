extends Label3D
## A simple Label3D for showing player interactable input prompts

## When player is in range of this interactable, this will display its input prompt.
## Note: setting this value will automatically connect all necessary signals at runtime.
@export var interactable: Interactable
## Text to be displayed to player. If show_input_action is true, this will be appended after "Press $Button to".
@export var prompt: String
## If multiple actions are tied to interactable's input_action, this index will select from those.
## If value is -1, displays all valid events in CSV form.
@export var idx: int
@export var show_input_action := true

func _ready() -> void:
	hide()
	_update_text()

	if not interactable: return
	if not interactable.interactor_entered.is_connected(_on_button_interactor_entered):
		interactable.interactor_entered.connect(_on_button_interactor_entered)
	if not interactable.interactor_exited.is_connected(_on_button_interactor_exited):
		interactable.interactor_exited.connect(_on_button_interactor_exited)


func _on_button_interactor_exited(_interactor: Node3D) -> void:
	hide()


func _on_button_interactor_entered(_interactor: Node3D) -> void:
	show()


func _update_text() -> void:
	var prompt_parts := []
	if show_input_action:
		prompt_parts.append("Press")
		var actions := InputMap.action_get_events(interactable.input_action)
		var action_text: String
		if idx < 0:
			prompt_parts.append(",".join(actions.map(func(x): return x.as_text())))
		elif idx < len(actions):
			prompt_parts.append(actions[idx].as_text())
		else:
			prompt_parts.append(actions[0].as_text())

		if len(prompt) > 0:
			prompt_parts.append("to")
	prompt_parts.append(prompt)
	text = " ".join(prompt_parts)
