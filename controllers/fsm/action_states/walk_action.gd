extends ControllerActionState

@export var walk_speed := 50.0
@export var move_left_action := "ui_left"
@export var move_right_action := "ui_right"
@export var move_up_action := "ui_up"
@export var move_down_action := "ui_down"

var _last_facing_direction: Vector3

func physics_update(state: PhysicsDirectBodyState3D) -> void: 
	var _walk_speed := _get_movement_vector(walk_speed)
	if _walk_speed.length() > 0:
		_last_facing_direction = _walk_speed.normalized()
	state.apply_central_force(_walk_speed)


func _get_movement_vector(speed: float) -> Vector3:
	var _input_dir := Input.get_vector(move_left_action, move_right_action, move_up_action, move_down_action)
	var _direction := Vector3(_input_dir.x, 0, _input_dir.y).normalized()
	return _direction * speed
