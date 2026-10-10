extends Camera3D

@export var target_a: Node3D
@export var target_b: Node3D
@export var offset: Vector3

@onready var _target: Node3D = target_a

var _following_target_a := true
var _perspective_switch_tween: Tween


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _perspective_switch_tween and _perspective_switch_tween.is_running(): return

	if Input.is_action_just_pressed("switch_perspective"):
		_following_target_a = not _following_target_a
		_perspective_switch_tween = create_tween()
		_target.process_mode = Node.PROCESS_MODE_DISABLED
		_target = target_a if _following_target_a else target_b
		_perspective_switch_tween.tween_property(self, "position", _target.position + offset, 1)
		return

	_target.process_mode = Node.PROCESS_MODE_INHERIT
	position = _target.position + offset

	
