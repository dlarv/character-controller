@abstract
extends Node
class_name ControllerActionState

@warning_ignore("unused_signal")
signal fsm_param_update_request(key: String, value: Variant)

@export var damping := Vector3.ZERO
@export var linear_damp_mode: RigidBody3D.DampMode

func setup(_controller: Node3D) -> void: pass
func process_update(_delta: float) -> void: pass
func physics_update(_state: PhysicsDirectBodyState3D) -> void: pass


func _calculate_damping(state: PhysicsDirectBodyState3D) -> void:
	var _damp := state.total_linear_damp if linear_damp_mode == RigidBody3D.DAMP_MODE_COMBINE else 0.0
	state.linear_velocity.x *= 1 - (damping.x + _damp) / Engine.physics_ticks_per_second
	state.linear_velocity.y *= 1 - (damping.y + _damp) / Engine.physics_ticks_per_second
	state.linear_velocity.z *= 1 - (damping.z + _damp) / Engine.physics_ticks_per_second


func propagate_substate(_state_key: Array[String]) -> void: pass
