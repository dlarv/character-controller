@tool
extends EditorPlugin

const InteractableScene := preload("res://addons/character_controller/interactables/interactable.gd")
const InteractorScene := preload("res://addons/character_controller/interactables/interactor.gd")
const InteractableIcon := preload("res://assets/hand-tap-svgrepo-com.svg")


func _enable_plugin() -> void:
	add_custom_type("Interactable", "Area3D", InteractableScene, InteractableIcon)
	add_custom_type("Interactor", "Area3D", InteractorScene, InteractableIcon)


func _disable_plugin() -> void:
	remove_custom_type("Interactable")
	remove_custom_type("Interactor")


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
