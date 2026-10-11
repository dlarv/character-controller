extends Label3D


func _on_button_interacted(package: Node, interactable: Interactable, interactor: Node3D) -> void:
	text = "%s pressed %s! Received %s as package." % [interactor.name, interactable.name, package.name]


func _on_button_interactor_exited(_interactor: Node3D) -> void:
	text = ""
