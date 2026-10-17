extends CharacterBody3D

@export var offset_a: Vector3
@export var offset_b: Vector3
@export var speed := 10.0

@onready var _pos_a := offset_a + global_position
@onready var _pos_b := offset_b + global_position
@onready var _target := _pos_a


func _physics_process(delta: float) -> void:
	if global_position.is_equal_approx(_pos_a):
		_target = _pos_b
	elif global_position.is_equal_approx(_pos_b):
		_target = _pos_a

	position.x = move_toward(position.x, _target.x, delta)
	position.z = move_toward(position.z, _target.z, delta)
