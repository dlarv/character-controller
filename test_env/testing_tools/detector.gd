extends Area3D

@export var property_name: String
@export var detector_label: String
@export_enum("max", "min", "culmulative")
var detection_type := "max":
	set(val):
		detection_type = val
		match detection_type:
			"max":
				_update_value = max
				%MeshInstance3D.get_active_material(0).albedo_color = Color.RED
			"min":
				_update_value = min
				%MeshInstance3D.get_active_material(0).albedo_color = Color.BLUE
			"culmulative":
				_update_value = func(a, b): return a + b
				%MeshInstance3D.get_active_material(0).albedo_color = Color.GREEN


@onready var property_path := NodePath(property_name)

var value := 0.0

var _last_target: Node3D
var _update_value: Callable

func _ready() -> void:
	$Label3D.text = detector_label
	$ResultsLabel3D.text = "%.3f" % value


func _physics_process(_delta: float) -> void:
	if _last_target:
		var pos = _last_target.get_indexed(property_path)
		value = _update_value.call(value, pos)


func _on_body_entered(body: Node3D) -> void:
	if body != _last_target:
		_last_target = body
	else:
		$ResultsLabel3D.text = "%.3f" % value



