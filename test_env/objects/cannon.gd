extends StaticBody3D

const Projectile := preload("res://test_env/objects/projectile.tscn")


@export var speed_range := Vector2(.5, 1.5)
@export var fire_rate_range := Vector2(.1, .8)
@export var size_range := Vector2(.8, 1.5)

var _timer: Timer
var _rapid_fire_mode := false


func _ready() -> void:
	_timer = Timer.new()
	_timer.autostart = true
	_timer.one_shot = false
	_timer.timeout.connect(_on_timer_timeout)
	_timer.wait_time = randf_range(fire_rate_range.x, fire_rate_range.y)
	add_child(_timer)
	_timer.start()


func _on_timer_timeout() -> void:
	var projectile := Projectile.instantiate()
	add_child(projectile)
	projectile.set_size(randf_range(size_range.x, size_range.y))
	projectile.position.x = randf_range(-1, 1) * scale.x
	projectile.position.y = randf_range(-1, 1) * scale.y
	projectile.apply_central_impulse(basis.z * randf_range(speed_range.x, speed_range.y))

	_timer.wait_time = randf_range(fire_rate_range.x, fire_rate_range.y)
	_timer.start()


func _on_interactable_interacted(package: Node, interactable: Interactable, interactor: Node3D) -> void:
	_rapid_fire_mode = not _rapid_fire_mode
	if _rapid_fire_mode:
		size_range /= 2
		fire_rate_range /= 5
		# speed_range *= 2
	else:
		size_range *= 2
		fire_rate_range *= 5
		# speed_range /= 2


