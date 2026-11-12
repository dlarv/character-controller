@tool
extends Interactor
class_name Grabber

signal grabbed_object(obj: PhysicsBody3D)
signal dropped_object()

var joint: Joint3D


func _ready() -> void:
	add_to_group(Grabbable.GRABBER_GROUP)

	if Engine.is_editor_hint() and root == null and get_parent() is PhysicsBody3D:
		root = get_parent()

	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)
	if not child_exiting_tree.is_connected(_on_child_exiting_tree):
		child_exiting_tree.connect(_on_child_exiting_tree)

	if not joint:
		for child in get_children():
			if child is Joint3D:
				joint = child
				break

	if not joint:
		push_warning("Grabber must have a Joint3D child in order to work")


func grab(other: PhysicsBody3D) -> void:
	if root == null or joint == null: return
	elif not joint.node_b:
		joint.node_a = root.get_path()
		joint.node_b = other.get_path()
		grabbed_object.emit(other)
	else:
		drop()


func drop() -> void:
	joint.node_a = NodePath()
	joint.node_b = NodePath()
	dropped_object.emit()


func set_enabled(val: bool) -> void:
	monitorable = val


func _get_configuration_warnings() -> PackedStringArray:
	if not joint:
		return ["Grabber must have a Joint3D child in order to work"]
	return []


func _on_child_entered_tree(node: Node) -> void:
	if node is Joint3D:
		joint = node


func _on_child_exiting_tree(node: Node) -> void:
	if node is Joint3D:
		joint = null
