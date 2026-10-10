extends Camera3D

@export var offset: Vector3
@export var targets: Array[Node3D]
@export var switch_delay := 0.5
@export var start_idx := 0

@onready var _target: Node3D = targets[start_idx] if len(targets) > 0 else null
@onready var _curr_target_idx := start_idx

var _perspective_switch_tween: Tween


func _ready():
	_next_perspective(start_idx)


func _process(_delta: float) -> void:
	if len(targets) == 0 or _target == null: return
	if _perspective_switch_tween and _perspective_switch_tween.is_running(): return

	if Input.is_action_just_pressed("switch_perspective"):
		_next_perspective((_curr_target_idx + 1) % len(targets))
		return

	position = _target.position + offset

	
func _next_perspective(idx: int) -> void:
	_curr_target_idx = idx
	_target.process_mode = Node.PROCESS_MODE_DISABLED
	_target = targets[_curr_target_idx]

	_perspective_switch_tween = create_tween()
	_perspective_switch_tween.tween_property(self, "position", _target.position + offset, switch_delay)
	_perspective_switch_tween.finished.connect(func():
		_target.process_mode = Node.PROCESS_MODE_INHERIT
	)

