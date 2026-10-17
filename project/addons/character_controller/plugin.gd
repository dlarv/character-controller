@tool
extends EditorPlugin

const InteractableScene := preload("uid://diev6fpp7dd4k")
const InteractorScene := preload("uid://d24g57moi63cx")
const InteractableIcon := preload("uid://m3m847qoxpd0")
const InteractorIcon := preload("uid://jq8ri4g3wpiw")
const GrabbableScene := preload("uid://ch7n1cjy556v7")
const GrabbableIcon := preload("uid://1qxooiure0ql")
const GrabberScene := preload("uid://b0vxc2nbll1aq")
const GrabberIcon := preload("uid://dfgxtm8kwmq8e")


func _enable_plugin() -> void:
	add_custom_type("Interactable", "Area3D", InteractableScene, InteractableIcon)
	add_custom_type("Interactor", "Area3D", InteractorScene, InteractorIcon)
	add_custom_type("Grabbable", "Area3D", GrabbableScene, GrabbableIcon)
	add_custom_type("Grabber", "Area3D", GrabberScene, GrabberIcon)


func _disable_plugin() -> void:
	remove_custom_type("Interactable")
	remove_custom_type("Interactor")


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
