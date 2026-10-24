#include "godot_cpp/classes/collision_object3d.hpp"
#include "godot_cpp/classes/engine.hpp"
#include "godot_cpp/classes/os.hpp"
#include "godot_cpp/classes/physics_direct_body_state3d.hpp"
#include "godot_cpp/core/math.hpp"
#include "godot_cpp/variant/utility_functions.hpp"
#include "godot_cpp/variant/vector3.hpp"
#include <cstdlib>
#include <cstring>
#define SRBC StandardRigidBodyController

#include "standard_rigid_body_controller.h"

void SRBC::_enter_tree() {
	set_can_sleep(true);
	initial_gravity_scale = get_gravity_scale();

	if(!is_contact_monitor_enabled()) {
		set_max_contacts_reported(DEFAULT_CONTACTS_REPORTED);
	}

	auto create_timer = [&](double time) {
		Timer* timer = memnew(Timer);
		timer->set_one_shot(true);
		timer->set_autostart(false);
		timer->set_wait_time(time);
		call_deferred("add_child", timer);
		return timer;
	};

	bool is_debug_build = OS::get_singleton()->is_debug_build();
	coyote_timer = create_timer(coyote_time);
	coyote_timer->connect(
		"timeout", 
		Callable(this, "on_coyote_timeout")
	);
	if(is_debug_build || variable_jump_frames > 0) {
		variable_jump_timer = create_timer(((double)variable_jump_frames) 
				/ Engine::get_singleton()->get_physics_ticks_per_second());
	}
	jump_buffer_timer = create_timer(jump_buffer_time);
	jump_buffer_timer->connect(
		"timeout", 
		Callable(this, "on_jump_buffer_timeout")
	);
	dash_buffer_timer = create_timer(dash_buffer_time);
	dash_buffer_timer->connect(
		"timeout", 
		Callable(this, "on_dash_buffer_timeout")
	);
	dash_timer = create_timer(dash_time);
	dash_timer->connect(
		"timeout", 
		Callable(this, "on_dash_timeout")
	);

	if(is_debug_build || heavy_fall_wait_time > 0) {
		heavy_fall_timer = create_timer(heavy_fall_wait_time);
	}
	heavy_fall_timer->connect(
		"timeout", 
		Callable(this, "on_heavy_fall_timeout")
	);
}

void SRBC::_unhandled_input(const Ref<InputEvent> &event) {
	if(sprint_enabled && can_sprint) {
		if(sprint_toggle_mode) {
			if(event->is_action_pressed(sprint_action)) {
				is_sprinting = true;
			}
			else if(event->is_action_released(sprint_action)) {
				is_sprinting = false;
			}
		} 
		else {
			if(event->is_action_pressed(sprint_action)) {
				is_sprinting = !is_sprinting;
			}
		}
	}
	if(jump_enabled && event->is_action_pressed(jump_action)) {
		jump_buffer_timer->start();
		jump_buffered = true;
	}
	if(dash_enabled && event->is_action_pressed(dash_action)) {
		dash_buffer_timer->start();
		dash_buffered = true;
	}
}

void SRBC::_integrate_forces(PhysicsDirectBodyState3D* state) {
	if(heavy_fall_timer != nullptr && !heavy_fall_timer->is_stopped()) {
		return;
	}

	Vector3 linear_velocity = state->get_linear_velocity();
	Vector3 global_position = get_global_position();

	if(is_dashing) {
		state->set_linear_velocity(dash_velocity);
		set_global_position(Vector3(
			global_position.x,
			dash_y_position,
			global_position.z
		));
		return;
	}

	h_speed = walk(h_speed, &last_facing_direction);
	state->apply_central_force(h_speed);
	calculate_damping(state);
	is_on_floor = calculate_if_on_floor(state, &skip_next_grounded_check);

	if(try_dash(state)) {}
	else if(try_jump(state)) {}
	else if(try_fall(falling_gravity_mod)) {}
	else {
		set_gravity_scale(initial_gravity_scale);
		can_jump = true;
		can_dash = true;
		if(is_heavy_fall && heavy_fall_timer != nullptr) {
			heavy_fall_timer->start();
		}
	}

	if(heavy_fall_threshold >= 0 && std::abs(linear_velocity.y) >= heavy_fall_threshold) {
		is_heavy_fall = true;
	}

}

Vector3 SRBC::walk(Vector3 prev_speed, Vector3* direction) {
	Vector3 curr_speed = get_movement(walk_speed);
	if(curr_speed.length() > 0) {
		*direction = curr_speed.normalized();
		if(Math::is_zero_approx(prev_speed.length()) && !is_sprinting) {
			emit_signal("state_stated", WALK_KEY);
		}
	}
	else if(prev_speed.length() > 0 && !is_sprinting) {
		emit_signal("state_finished", WALK_KEY);
	}
	return curr_speed;
}

bool SRBC::try_dash(PhysicsDirectBodyState3D* state) {
	if(!dash_enabled && !can_dash) return false;
	if(!dash_buffered) return false;

	is_dashing = true;
	dash_timer->start();
	state->set_linear_velocity(Vector3(0, 0, 0));

	Vector3 direction = last_facing_direction;
	double speed = dash_length / dash_time;
	dash_velocity = direction * speed;
	state->set_linear_velocity(dash_velocity);

	dash_y_position = get_global_position().y;

	return true;
}

bool SRBC::try_jump(PhysicsDirectBodyState3D* state) {
	if(jump_enabled 
			&& jump_buffered 
			&& can_jump) {
		if(variable_jump_frames > 0 && variable_jump_timer->is_stopped()) {
			variable_jump_timer->start();
		}
		can_jump = false;
		coyote_timer->stop();
		Vector3 vel = state->get_linear_velocity();
		state->set_linear_velocity(Vector3(
			vel.x,
			0,
			vel.z
		));
		jump(state);
		is_jumping = true;
		return true;
	}
	else if(Input::get_singleton()->is_action_pressed(jump_action) 
			&& variable_jump_frames > 0 
			&& variable_jump_timer->is_stopped()) {
		jump(state, variable_jump_amount);
		return true;
	}
	if(is_jumping) {
		is_jumping = false;
		emit_signal("state_finished", JUMP_KEY);
	}
	return false;

}
void SRBC::jump(PhysicsDirectBodyState3D* state, double velocity_mod) {
	// 0 = v^2 + 2ax
	double speed = Math::sqrt(2 * std::abs(state->get_total_gravity().y) * jump_height) * velocity_mod;
	state->apply_central_impulse(Vector3::UP * speed);
	skip_next_grounded_check = true;
}

bool SRBC::try_fall(double gravity_mod) {
	// Don't apply heavier gravity before coyote time runs out
	if(!coyote_timer->is_stopped()) return false;
	if(is_on_floor) return false;
	if(can_jump) {
		coyote_timer->start();
		// player is falling, just not with heavier gravity
		return true;
	}
	if(is_falling) {
		set_gravity_scale(gravity_mod);
	}
	return true;
}

bool SRBC::enable_ability(StringName key, bool enabled){
	// Can't use CONST StringName in switch, so ifelse instead
	if(key == SRBC::SPRINT_KEY) {
		SRBC::set_sprint_enabled(enabled);
		return true;
	}
	else if(key == SRBC::DASH_KEY) {
		SRBC::set_dash_enabled(enabled);
		return true;
	}
	else if(key == SRBC::JUMP_KEY) {
		SRBC::set_jump_enabled(enabled);
		return true;
	}
	return false;
}

TypedArray<StringName> SRBC::enable_abilities(TypedArray<StringName> keys, bool enabled){
	TypedArray<StringName> arr;
	for(const auto& key: keys) {
		if(!SRBC::enable_ability(key, enabled)) {
			arr.push_back(key);
		}
	}
	return arr;
}

bool SRBC::refresh_ability(StringName key, bool enabled){
	// Can't use CONST StringName in switch, so ifelse instead
	if(key == SRBC::SPRINT_KEY) {
		SRBC::set_can_sprint(enabled);
		return true;
	}
	else if(key == SRBC::DASH_KEY) {
		SRBC::set_can_dash(enabled);
		return true;
	}
	else if(key == SRBC::JUMP_KEY) {
		SRBC::set_can_jump(enabled);
		return true;
	}
	return false;
}

TypedArray<StringName> SRBC::refresh_abilities(TypedArray<StringName> keys, bool enabled){
	TypedArray<StringName> arr;
	for(const auto& key: keys) {
		if(!SRBC::refresh_ability(key, enabled)) {
			arr.push_back(key);
		}
	}
	return arr;
}

bool SRBC::grant_ability(StringName key, bool enabled){
	emit_signal("ability_granted", key);
	return SRBC::enable_ability(key, enabled);
}

Dictionary SRBC::get_state_data() {
	Dictionary output;

	Dictionary walk_dict;
	output[SRBC::WALK_KEY] = walk_dict;
	walk_dict["speed"] = SRBC::walk_speed;

	Dictionary sprint_dict;
	output[SRBC::SPRINT_KEY] = sprint_dict;
	sprint_dict["enabled"] = SRBC::sprint_enabled;
	sprint_dict["can"] = SRBC::can_sprint;
	sprint_dict["speed"] = SRBC::sprint_speed;

	Dictionary dash_dict;
	output[SRBC::DASH_KEY] = dash_dict;
	dash_dict["enabled"] = SRBC::dash_enabled;
	dash_dict["can"] = SRBC::can_dash;
	dash_dict["length"] = SRBC::dash_length;
	dash_dict["duration"] = SRBC::dash_time;

	Dictionary jump_dict;
	output[SRBC::JUMP_KEY] = jump_dict;
	jump_dict["enabled"] = SRBC::jump_enabled;
	jump_dict["can"] = SRBC::can_jump;
	jump_dict["height"] = SRBC::jump_height;

	return output;
}

void SRBC::calculate_damping(PhysicsDirectBodyState3D* state) {
	double tps = Engine::get_singleton()->get_physics_ticks_per_second();
	Vector3 external_damp = Vector3(1, 1, 1) * state->get_total_linear_damp();
	Vector3 internal_damp = is_on_floor ? grounded_damping : ungrounded_damping;
	Vector3 initial_velocity = state->get_linear_velocity();
	state->set_linear_velocity(Vector3(
		initial_velocity.x * (1 - internal_damp.x / tps),
		initial_velocity.y * (1 - internal_damp.y / tps),
		initial_velocity.z * (1 - internal_damp.z / tps)
	));

}

Vector3 SRBC::get_movement(double speed) {
	Vector2 input_dir = Input::get_singleton()->get_vector(move_left_action, move_right_action, move_up_action, move_down_action);
	Vector3 direction = Vector3(input_dir.x, 0, input_dir.y).normalized();
	return direction * speed;
}


bool SRBC::calculate_if_on_floor(PhysicsDirectBodyState3D* state, bool* skip_check) {
	if(*skip_check) {
		*skip_check = false;
		return false;
	}

	for(int i = 0; i < state->get_contact_count(); i++) {
		if(floor_collision_layer > 0) {
			CollisionObject3D* obj = (CollisionObject3D*)state->get_contact_collider_object(i);
			if(obj->get_collision_layer() & floor_collision_layer) {
				continue;
			}
		}
		Vector3 normal = state->get_contact_local_normal(i);
		if(normal.dot(Vector3::UP) >= floor_normal_threshold) {
			is_on_floor = true;
			return true;
		}
	}
	return false;
}
