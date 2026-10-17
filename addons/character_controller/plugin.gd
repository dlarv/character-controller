@tool
extends EditorPlugin

const Interactable := preload("uid://diev6fpp7dd4k")
const Interactor := preload("uid://d24g57moi63cx")
const InteractableIcon := preload("uid://m3m847qoxpd0")
const InteractorIcon := preload("uid://jq8ri4g3wpiw")
const Grabbable := preload("uid://ch7n1cjy556v7")
const GrabbableIcon := preload("uid://1qxooiure0ql")
const Grabber := preload("uid://b0vxc2nbll1aq")
const GrabberIcon := preload("uid://dfgxtm8kwmq8e")
const RBController := preload("uid://275scp4h71ib")
const RBControllerIcon := preload("uid://bdrsjlid525ke")


func _enter_tree() -> void:
	print("Character controller plugin enabled")
	_add_types()


func _exit_tree() -> void:
	print("Character controller plugin disabled")
	_remove_types()


func _add_types() -> void:
	add_custom_type("Interactable", "Area3D", Interactable, InteractableIcon)
	add_custom_type("Interactor", "Area3D", Interactor, InteractorIcon)
	add_custom_type("Grabbable", "Area3D", Grabbable, GrabbableIcon)
	add_custom_type("Grabber", "Area3D", Grabber, GrabberIcon)
	add_custom_type("StdRigidBodyController", "RigidBody3D", RBController, RBControllerIcon)

func _remove_types() -> void:
	remove_custom_type("Interactable")
	remove_custom_type("Interactor")
	remove_custom_type("Grabbable")
	remove_custom_type("Grabber")
	remove_custom_type("StdRigidBodyController")
