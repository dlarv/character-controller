@tool
extends Camera3D
class_name OrbitalCameraController
## Controller Module allowing player to rotate camera around Controller.


## Controller this camera should orbit. Defaults to parent, if applicable.
@export var target: RigidBody3D = null
## Overrides target.ignore_rotation, setting it to not free_cam_enabled
@export var override_ignore_rotation := true
## If true, overrides target.axis_lock_angular_y when enabled
@export var override_angular_lock := true
@export_group("Camera Movement Controls")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var free_cam_enabled := false:
	set(val):
		free_cam_enabled = val
		if target == null: return
		if override_ignore_rotation:
			target.set_deferred("ignore_rotation", not free_cam_enabled)
		if override_angular_lock:
			target.set_deferred("axis_lock_angular_y", _initial_angular_y_lock and not val)
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var camera_left_action := ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var camera_right_action := ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var camera_up_action := ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var camera_down_action := ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var camera_reset_action := ""
@export var initial_offset := Vector3(0, 3, 5)
@export var camera_pan_speed := 10.0
@export_custom(PROPERTY_HINT_RANGE, "-90,90,degrees") var camera_vertical_angle_lock := Vector2(-90, 0)

var _radius: float
var _initial_angular_y_lock: bool

func _ready() -> void:
	var _parent := get_parent()
	if not target and _parent is RigidBody3D:
		target = _parent

	reset()

	_radius = global_position.distance_to(target.global_position)

	_initial_angular_y_lock = target.axis_lock_angular_y

	if override_ignore_rotation:
		target.ignore_rotation = not free_cam_enabled


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if len(camera_reset_action) > 0 and Input.is_action_just_pressed(camera_reset_action):
		reset()
	if not free_cam_enabled: return

	# Rotate target Controller
	var _cam_rotation := Input.get_axis(camera_left_action, camera_right_action)
	target.apply_torque(Vector3.UP * _cam_rotation * camera_pan_speed * delta)
	
	# Rotate self
	var _cam_v_rotation := Input.get_axis(camera_up_action, camera_down_action) * delta * camera_pan_speed
	if is_zero_approx(_cam_v_rotation): return

	var _phi: float = clampf(
		rotation_degrees.x + _cam_v_rotation,
		camera_vertical_angle_lock.x,
		camera_vertical_angle_lock.y
	)

	var _rad := deg_to_rad(-_phi)
	position.z = _radius * cos(_rad)
	position.y = _radius * sin(_rad)
	rotation_degrees.x = _phi


func reset() -> void:
	target.angular_velocity = Vector3.ZERO
	target.global_rotation.y = 0
	position = initial_offset
	look_at(target.global_position)


func set_enabled(val: bool, reset_transform:=true) -> void:
	free_cam_enabled = val

	if reset_transform:
		call_deferred("reset")


func _get_configuration_warnings() -> PackedStringArray:
	var output := []

	if not get_parent() is RigidBody3D:
		output.append("For CameraController to work properly, it must be child of RigidBody3D")

	if not free_cam_enabled: return output

	for action in [camera_left_action, camera_right_action, camera_up_action, camera_down_action]:
		if len(action) == 0:
			output.append("Free cam mode is enabled, but one or more camera control actions are undefined.")
			break
	return output
