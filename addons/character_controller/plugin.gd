@tool
extends EditorPlugin

const InteractableScene := preload("res://addons/character_controller/interactables/interactable.gd")
const InteractableIcon := preload("res://assets/hand-tap-svgrepo-com.svg")


func _enable_plugin() -> void:
	add_custom_type("Interactable", "Area3D", InteractableScene, InteractableIcon)


func _disable_plugin() -> void:
	remove_custom_type("Interactable")


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
