extends Node3D


func _on_interactable_interacted(_package: Node, _interactable: Interactable, interactor: Interactor) -> void:
	interactor.root.grant_ability("dash")
