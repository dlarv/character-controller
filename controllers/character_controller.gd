extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var jump_height: float
@export var jump_up_time: float


var _height := []
var _gravity_scale := 1.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * _gravity_scale

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = _get_jump_velocity()
		_set_jump_acceleration(velocity.y)
		_height = []
		print("JUMP")
	
	if not is_on_floor():
		_height.append(position.y)
	elif len(_height) > 0:
		_height = []
	else:
		print("GROUNDED")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _get_jump_velocity() -> float:
	return 2 * jump_height / jump_up_time


func _set_jump_acceleration(v: float) -> void:
	_gravity_scale = pow(v, 2) / (2 * jump_height) / 9.8
