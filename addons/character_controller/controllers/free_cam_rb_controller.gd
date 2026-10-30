@tool
extends StandardRBController
class_name FreeCamRBController
## Builds off of StandardRBController, adding camera controls.
##
## Allows player to freely rotate camera, independent of Controller.
## If no Camera3D found in children, one will be created at runtime.


@export_group("Camera Movement Controls")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var free_cam_enabled := false
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var camera_left_action := ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var camera_right_action := ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var camera_up_action := ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var camera_down_action := ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var camera_zoom_action := ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var camera_reset_action := ""
@export var initial_offset := Vector3(0, 3, 5)
@export var camera_pan_speed := 0.5
@export var camera_zoom_speed := 3.0
@export_custom(PROPERTY_HINT_RANGE, "-90,90,degrees") var camera_vertical_angle_lock := Vector2()

var _camera: Camera3D
var _radius: float

func _ready() -> void:
	for child in get_children():
		if child is Camera3D:
			_camera = child
			break
	
	if _camera == null:
		_camera = Camera3D.new()
		add_child(_camera)
	
	reset_camera()

	_radius = _camera.global_position.distance_to(global_position)
	

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	super._integrate_forces(state)

	if not free_cam_enabled: return

	var _cam_rotation := Input.get_axis(camera_left_action, camera_right_action)
	state.apply_torque(Vector3.UP * _cam_rotation * camera_pan_speed)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not free_cam_enabled: return
	if len(camera_reset_action) > 0 and Input.is_action_just_pressed(camera_reset_action):
		reset_camera()
	
	var _cam_v_rotation := Input.get_axis(camera_up_action, camera_down_action) * delta * camera_pan_speed
	if is_zero_approx(_cam_v_rotation): return

	var _phi: float = clampf(
		_camera.rotation_degrees.x + _cam_v_rotation,
		camera_vertical_angle_lock.x,
		camera_vertical_angle_lock.y
	)

	var _rad := deg_to_rad(-_phi)
	_camera.position.z = _radius * cos(_rad)
	_camera.position.y = _radius * sin(_rad)
	_camera.rotation_degrees.x = _phi


func _get_movement_vector(speed: float) -> Vector3:
	var _z_dir := Input.get_axis(move_up_action, move_down_action)
	var _x_dir := Input.get_axis(move_left_action, move_right_action)
	var _direction := (transform.basis.x * _x_dir) + (transform.basis.z * _z_dir)

	return _direction * speed


func _get_configuration_warnings() -> PackedStringArray:
	var output := super._get_configuration_warnings()
	if not free_cam_enabled: return []
	for action in [camera_left_action, camera_right_action, camera_up_action, camera_down_action]:
		if len(action) == 0:
			output.append("Free cam mode is enabled, but one or more camera control actions are undefined.")
			break
	return output


func reset_camera() -> void:
	global_rotation_degrees.y = 0
	_camera.global_position = global_position + initial_offset
	_camera.look_at(global_position)

