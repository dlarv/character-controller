extends Label3D


var _counter := 0

func _process(_delta: float) -> void:
	text = "%d" % _counter


func _on_button_interacted(_package: Node, _interactable: Interactable, _interactor: Node3D) -> void:
	_counter += 1

