extends RigidBody3D


func _enter_tree() -> void:
	await get_tree().create_timer(1.0).timeout
	queue_free()


func set_size(size: float):
	$MeshInstance3D.mesh.radius *= size
	$MeshInstance3D.mesh.height *= size
	$CollisionShape3D.shape.radius *= size
