extends ControllerActionState


var curr_substate: String


func physics_update(state: PhysicsDirectBodyState3D) -> void: 
	print(curr_substate)


func propagate_substate(state_key: Array[String]) -> void:
	if len(state_key) > 0:
		curr_substate = state_key[0]
