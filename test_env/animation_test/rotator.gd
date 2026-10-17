extends Node3D


@export var controller: RigidBody3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not controller: return
	var target: Vector3 = controller.last_facing_direction

	rotation.y = atan2(target.x, target.z)
