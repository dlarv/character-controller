extends Area3D

@export var speed := 10.0


func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is RigidBody3D:
			body.apply_central_force(speed * basis.y)
