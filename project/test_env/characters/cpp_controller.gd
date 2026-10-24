extends StandardRigidBodyController


func _ready() -> void:
	sprint_enabled = false
	print(sprint_enabled)
	enable_ability(SPRINT_KEY, true)
	print(sprint_enabled)
