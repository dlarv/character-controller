#pragma once

#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/classes/wrapped.hpp"
#include "godot_cpp/variant/variant.hpp"
#include "godot_cpp/variant/utility_functions.hpp"

#include <godot_cpp/classes/rigid_body3d.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/templates/vector.hpp>


using namespace godot;
class StandardRigidBodyController: public RigidBody3D {
	GDCLASS(StandardRigidBodyController, RigidBody3D)

private:
	/* EXPORTED PROPERTIES */
	Vector3 grounded_damping;
	Vector3 ungrounded_damping;
	double floor_normal_threshold = 0.8;
	int floor_collision_layer = 0xFFFFFFFF;
	double falling_gravity_mod = 2;
	double falling_threshold = 0;
	double heavy_fall_threshold = 50;
	double heavy_fall_wait_time = 0.2;
	double walk_speed = 50;
	String move_left_action = "ui_left";
	String move_right_action = "ui_right";
	String move_up_action = "ui_up";
	String move_down_action = "ui_down";
	bool sprint_enabled = true;
	String sprint_action = "";
	double sprint_speed = 125;
	bool sprint_toggle_mode = true;
	bool jump_enabled = true;
	String jump_action = "ui_select";
	double jump_height = 5;
	double coyote_time = 0.1;
	int variable_jump_frames = 0; 
	double variable_jump_amount = 0.01;
	double jump_buffer_time = 0.1;
	bool dash_enabled = true;
	String dash_action = "";
	double dash_length = 3;
	double dash_time = 0.1;
	double dash_buffer_time = 0.1;

	/* NON-EXPORTED PROPERTIES */
	bool is_sprinting = false;
public:
	/* CONSTANTS */
	const StringName WALK_KEY = "walk";
	const StringName SPRINT_KEY = "sprint";
	const StringName JUMP_KEY = "jump";
	const StringName DASH_KEY = "dash";
	const int DEFAULT_CONTACTS_REPORTED = 100;

	/* (DE)CONSTRUCTOR */
	StandardRigidBodyController() = default;
	~StandardRigidBodyController() override = default;

	/* METHODS */
	bool enable_ability(StringName key, bool enabled);
	TypedArray<StringName> enable_abilities(TypedArray<StringName> key, bool enabled);
	bool refresh_ability(StringName key, bool enabled);
	TypedArray<StringName> refresh_abilities(TypedArray<StringName> key, bool enabled);
	bool grant_ability(StringName key, bool enabled);

	/* EXPORTED GETTERS AND SETTERS */
	Vector3 get_grounded_damping() const { return grounded_damping; }
	void set_grounded_damping(const Vector3 v) { grounded_damping = v; }
	void set_ungrounded_damping(const Vector3 p) { ungrounded_damping = p; }
	Vector3 get_ungrounded_damping() const { return ungrounded_damping; }
	void set_floor_normal_threshold(const double p) { floor_normal_threshold = p; }
	double get_floor_normal_threshold() const { return floor_normal_threshold; }
	void set_floor_collision_layer(const int p) { floor_collision_layer = p; }
	int get_floor_collision_layer() const { return floor_collision_layer; }
	void set_falling_gravity_mod(const double p) { falling_gravity_mod = p; }
	double get_falling_gravity_mod() const { return falling_gravity_mod; }
	void set_falling_threshold(const double p) { falling_threshold = p; }
	double get_falling_threshold() const { return falling_threshold; }
	void set_heavy_fall_threshold(const double p) { heavy_fall_threshold = p; }
	double get_heavy_fall_threshold() const { return heavy_fall_threshold; }
	void set_heavy_fall_wait_time(const double p) { heavy_fall_wait_time = p; }
	double get_heavy_fall_wait_time() const { return heavy_fall_wait_time; }
	void set_walk_speed(const double p) { walk_speed = p; }
	double get_walk_speed() const { return walk_speed; }
	void set_move_left_action(const String p) { move_left_action = p; }
	String get_move_left_action() const { return move_left_action; }
	void set_move_right_action(const String p) { move_right_action = p; }
	String get_move_right_action() const { return move_right_action; }
	void set_move_up_action(const String p) { move_up_action = p; }
	String get_move_up_action() const { return move_up_action; }
	void set_move_down_action(const String p) { move_down_action = p; }
	String get_move_down_action() const { return move_down_action; }
	void set_sprint_enabled(const bool p) { 
		sprint_enabled = p; 
		is_sprinting = is_sprinting && p;
	}
	bool get_sprint_enabled() const { return sprint_enabled; }
	void set_sprint_action(const String p) { sprint_action = p; }
	String get_sprint_action() const { return sprint_action; }
	void set_sprint_speed(const double p) { sprint_speed = p; }
	double get_sprint_speed() const { return sprint_speed; }
	void set_sprint_toggle_mode(const bool p) { sprint_toggle_mode = p; }
	bool get_sprint_toggle_mode() const { return sprint_toggle_mode; }
	void set_jump_enabled(const bool p) { jump_enabled = p; }
	bool get_jump_enabled() const { return jump_enabled; }
	void set_jump_action(const String p) { jump_action = p; }
	String get_jump_action() const { return jump_action; }
	void set_jump_height(const double p) { jump_height = p; }
	double get_jump_height() const { return jump_height; }
	void set_coyote_time(const double p) { coyote_time = p; }
	double get_coyote_time() const { return coyote_time; }
	void set_variable_jump_frames(const int p) { variable_jump_frames = p; }
	int get_variable_jump_frames() const { return variable_jump_frames; }
	void set_variable_jump_amount(const double p) { variable_jump_amount = p; }
	double get_variable_jump_amount() const { return variable_jump_amount; }
	void set_jump_buffer_time(const double p) { jump_buffer_time = p; }
	double get_jump_buffer_time() const { return jump_buffer_time; }
	void set_dash_enabled(const bool p) { dash_enabled = p; }
	bool get_dash_enabled() const { return dash_enabled; }
	void set_dash_action(const String p) { dash_action = p; }
	String get_dash_action() const { return dash_action; }
	void set_dash_length(const double p) { dash_length = p; }
	double get_dash_length() const { return dash_length; }
	void set_dash_time(const double p) { dash_time = p; }
	double get_dash_time() const { return dash_time; }
	void set_dash_buffer_time(const double p) { dash_buffer_time = p; }
	double get_dash_buffer_time() const { return dash_buffer_time; }

	/* NON-EXPORTED GETTERS AND SETTERS */
	void set_is_sprinting(const bool p) { is_sprinting = p; }
	bool get_is_sprinting() const { return is_sprinting; }

protected:
	static void _bind_methods() {
		ADD_SIGNAL(MethodInfo("state_started", PropertyInfo(Variant::STRING_NAME, "key")));
		ADD_SIGNAL(MethodInfo("state_finished", PropertyInfo(Variant::STRING_NAME, "key")));
		ADD_SIGNAL(MethodInfo("ability_granted", PropertyInfo(Variant::STRING_NAME, "key")));

		ClassDB::bind_method(
			D_METHOD("set_grounded_damping", "grounded_damping"), 
			&StandardRigidBodyController::set_grounded_damping
		);
		ClassDB::bind_method(
			D_METHOD("get_grounded_damping"), 
			&StandardRigidBodyController::get_grounded_damping
		);
		ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "grounded_damping"), "set_grounded_damping", "get_grounded_damping");

		ClassDB::bind_method(
			D_METHOD("set_ungrounded_damping", "ungrounded_damping"), 
			&StandardRigidBodyController::set_ungrounded_damping
		);
		ClassDB::bind_method(
			D_METHOD("get_ungrounded_damping"), 
			&StandardRigidBodyController::get_ungrounded_damping
		);
		ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "ungrounded_damping"), "set_ungrounded_damping", "get_ungrounded_damping");

		ClassDB::bind_method(
			D_METHOD("set_floor_normal_threshold", "floor_normal_threshold"), 
			&StandardRigidBodyController::set_floor_normal_threshold
		);
		ClassDB::bind_method(
			D_METHOD("get_floor_normal_threshold"), 
			&StandardRigidBodyController::get_floor_normal_threshold
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "floor_normal_threshold", PROPERTY_HINT_RANGE, "0,1"), "set_floor_normal_threshold", "get_floor_normal_threshold");

		ClassDB::bind_method(
			D_METHOD("set_floor_collision_layer", "floor_collision_layer"), 
			&StandardRigidBodyController::set_floor_collision_layer
		);
		ClassDB::bind_method(
			D_METHOD("get_floor_collision_layer"), 
			&StandardRigidBodyController::get_floor_collision_layer
		);
		ADD_PROPERTY(PropertyInfo(Variant::INT, "floor_collision_layer", PROPERTY_HINT_LAYERS_3D_PHYSICS), "set_floor_collision_layer", "get_floor_collision_layer");

		ClassDB::bind_method(
			D_METHOD("set_falling_gravity_mod", "falling_gravity_mod"), 
			&StandardRigidBodyController::set_falling_gravity_mod
		);
		ClassDB::bind_method(
			D_METHOD("get_falling_gravity_mod"), 
			&StandardRigidBodyController::get_falling_gravity_mod
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "falling_gravity_mod", PROPERTY_HINT_RANGE, "0.01,1000"), "set_falling_gravity_mod", "get_falling_gravity_mod");

		ClassDB::bind_method(
			D_METHOD("set_falling_threshold", "falling_threshold"), 
			&StandardRigidBodyController::set_falling_threshold
		);
		ClassDB::bind_method(
			D_METHOD("get_falling_threshold"), 
			&StandardRigidBodyController::get_falling_threshold
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "falling_threshold"), "set_falling_threshold", "get_falling_threshold");

		ClassDB::bind_method(
			D_METHOD("set_heavy_fall_threshold", "heavy_fall_threshold"), 
			&StandardRigidBodyController::set_heavy_fall_threshold
		);
		ClassDB::bind_method(
			D_METHOD("get_heavy_fall_threshold"), 
			&StandardRigidBodyController::get_heavy_fall_threshold
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "heavy_fall_threshold"), "set_heavy_fall_threshold", "get_heavy_fall_threshold");

		ClassDB::bind_method(
			D_METHOD("set_heavy_fall_wait_time", "heavy_fall_wait_time"), 
			&StandardRigidBodyController::set_heavy_fall_wait_time
		);
		ClassDB::bind_method(
			D_METHOD("get_heavy_fall_wait_time"), 
			&StandardRigidBodyController::get_heavy_fall_wait_time
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "heavy_fall_wait_time"), "set_heavy_fall_wait_time", "get_heavy_fall_wait_time");

		ClassDB::bind_method(
			D_METHOD("set_walk_speed", "walk_speed"), 
			&StandardRigidBodyController::set_walk_speed
		);
		ClassDB::bind_method(
			D_METHOD("get_walk_speed"), 
			&StandardRigidBodyController::get_walk_speed
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "walk_speed"), "set_walk_speed", "get_walk_speed");

		ClassDB::bind_method(
			D_METHOD("set_move_left_action", "move_left_action"), 
			&StandardRigidBodyController::set_move_left_action
		);
		ClassDB::bind_method(
			D_METHOD("get_move_left_action"), 
			&StandardRigidBodyController::get_move_left_action
		);
		ADD_PROPERTY(PropertyInfo(Variant::STRING, "move_left_action",PROPERTY_HINT_INPUT_NAME, "show_builtin"), "set_move_left_action", "get_move_left_action");

		ClassDB::bind_method(
			D_METHOD("set_move_right_action", "move_right_action"), 
			&StandardRigidBodyController::set_move_right_action
		);
		ClassDB::bind_method(
			D_METHOD("get_move_right_action"), 
			&StandardRigidBodyController::get_move_right_action
		);
		ADD_PROPERTY(PropertyInfo(Variant::STRING, "move_right_action",PROPERTY_HINT_INPUT_NAME, "show_builtin"), "set_move_right_action", "get_move_right_action");

		ClassDB::bind_method(
			D_METHOD("set_move_up_action", "move_up_action"), 
			&StandardRigidBodyController::set_move_up_action
		);
		ClassDB::bind_method(
			D_METHOD("get_move_up_action"), 
			&StandardRigidBodyController::get_move_up_action
		);
		ADD_PROPERTY(PropertyInfo(Variant::STRING, "move_up_action",PROPERTY_HINT_INPUT_NAME, "show_builtin"), "set_move_up_action", "get_move_up_action");

		ClassDB::bind_method(
			D_METHOD("set_move_down_action", "move_down_action"), 
			&StandardRigidBodyController::set_move_down_action
		);
		ClassDB::bind_method(
			D_METHOD("get_move_down_action"), 
			&StandardRigidBodyController::get_move_down_action
		);
		ADD_PROPERTY(PropertyInfo(Variant::STRING, "move_down_action",PROPERTY_HINT_INPUT_NAME, "show_builtin"), "set_move_down_action", "get_move_down_action");

		ADD_GROUP("Sprint", "");
		ClassDB::bind_method(
			D_METHOD("set_sprint_enabled", "sprint_enabled"), 
			&StandardRigidBodyController::set_sprint_enabled
		);
		ClassDB::bind_method(
			D_METHOD("get_sprint_enabled"), 
			&StandardRigidBodyController::get_sprint_enabled
		);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "sprint_enabled", PROPERTY_HINT_GROUP_ENABLE), "set_sprint_enabled", "get_sprint_enabled");

		ClassDB::bind_method(
			D_METHOD("set_sprint_action", "sprint_action"), 
			&StandardRigidBodyController::set_sprint_action
		);
		ClassDB::bind_method(
			D_METHOD("get_sprint_action"), 
			&StandardRigidBodyController::get_sprint_action
		);
		ADD_PROPERTY(PropertyInfo(Variant::STRING, "sprint_action",PROPERTY_HINT_INPUT_NAME, "show_builtin"), "set_sprint_action", "get_sprint_action");

		ClassDB::bind_method(
			D_METHOD("set_sprint_speed", "sprint_speed"), 
			&StandardRigidBodyController::set_sprint_speed
		);
		ClassDB::bind_method(
			D_METHOD("get_sprint_speed"), 
			&StandardRigidBodyController::get_sprint_speed
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "sprint_speed"), "set_sprint_speed", "get_sprint_speed");

		ClassDB::bind_method(
			D_METHOD("set_sprint_toggle_mode", "sprint_toggle_mode"), 
			&StandardRigidBodyController::set_sprint_toggle_mode
		);
		ClassDB::bind_method(
			D_METHOD("get_sprint_toggle_mode"), 
			&StandardRigidBodyController::get_sprint_toggle_mode
		);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "sprint_toggle_mode"), "set_sprint_toggle_mode", "get_sprint_toggle_mode");

		ADD_GROUP("Jump", "");
		ClassDB::bind_method(
			D_METHOD("set_jump_enabled", "jump_enabled"), 
			&StandardRigidBodyController::set_jump_enabled
		);
		ClassDB::bind_method(
			D_METHOD("get_jump_enabled"), 
			&StandardRigidBodyController::get_jump_enabled
		);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "jump_enabled", PROPERTY_HINT_GROUP_ENABLE), "set_jump_enabled", "get_jump_enabled");

		ClassDB::bind_method(
			D_METHOD("set_jump_action", "jump_action"), 
			&StandardRigidBodyController::set_jump_action
		);
		ClassDB::bind_method(
			D_METHOD("get_jump_action"), 
			&StandardRigidBodyController::get_jump_action
		);
		ADD_PROPERTY(PropertyInfo(Variant::STRING, "jump_action",PROPERTY_HINT_INPUT_NAME, "show_builtin"), "set_jump_action", "get_jump_action");

		ClassDB::bind_method(
			D_METHOD("set_jump_height", "jump_height"), 
			&StandardRigidBodyController::set_jump_height
		);
		ClassDB::bind_method(
			D_METHOD("get_jump_height"), 
			&StandardRigidBodyController::get_jump_height
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "jump_height"), "set_jump_height", "get_jump_height");

		ClassDB::bind_method(
			D_METHOD("set_coyote_time", "coyote_time"), 
			&StandardRigidBodyController::set_coyote_time
		);
		ClassDB::bind_method(
			D_METHOD("get_coyote_time"), 
			&StandardRigidBodyController::get_coyote_time
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "coyote_time"), "set_coyote_time", "get_coyote_time");

		ClassDB::bind_method(
			D_METHOD("set_variable_jump_frames", "variable_jump_frames"), 
			&StandardRigidBodyController::set_variable_jump_frames
		);
		ClassDB::bind_method(
			D_METHOD("get_variable_jump_frames"), 
			&StandardRigidBodyController::get_variable_jump_frames
		);
		ADD_PROPERTY(PropertyInfo(Variant::INT, "variable_jump_frames"), "set_variable_jump_frames", "get_variable_jump_frames");

		ClassDB::bind_method(
			D_METHOD("set_variable_jump_amount", "variable_jump_amount"), 
			&StandardRigidBodyController::set_variable_jump_amount
		);
		ClassDB::bind_method(
			D_METHOD("get_variable_jump_amount"), 
			&StandardRigidBodyController::get_variable_jump_amount
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "variable_jump_amount"), "set_variable_jump_amount", "get_variable_jump_amount");

		ClassDB::bind_method(
			D_METHOD("set_jump_buffer_time", "jump_buffer_time"), 
			&StandardRigidBodyController::set_jump_buffer_time
		);
		ClassDB::bind_method(
			D_METHOD("get_jump_buffer_time"), 
			&StandardRigidBodyController::get_jump_buffer_time
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "jump_buffer_time"), "set_jump_buffer_time", "get_jump_buffer_time");

		ADD_GROUP("Dash", "");
		ClassDB::bind_method(
			D_METHOD("set_dash_enabled", "dash_enabled"), 
			&StandardRigidBodyController::set_dash_enabled
		);
		ClassDB::bind_method(
			D_METHOD("get_dash_enabled"), 
			&StandardRigidBodyController::get_dash_enabled
		);
		ADD_PROPERTY(PropertyInfo(Variant::BOOL, "dash_enabled", PROPERTY_HINT_GROUP_ENABLE), "set_dash_enabled", "get_dash_enabled");

		ClassDB::bind_method(
			D_METHOD("set_dash_action", "dash_action"), 
			&StandardRigidBodyController::set_dash_action
		);
		ClassDB::bind_method(
			D_METHOD("get_dash_action"), 
			&StandardRigidBodyController::get_dash_action
		);
		ADD_PROPERTY(PropertyInfo(Variant::STRING, "dash_action",PROPERTY_HINT_INPUT_NAME, "show_builtin"), "set_dash_action", "get_dash_action");

		ClassDB::bind_method(
			D_METHOD("set_dash_length", "dash_length"), 
			&StandardRigidBodyController::set_dash_length
		);
		ClassDB::bind_method(
			D_METHOD("get_dash_length"), 
			&StandardRigidBodyController::get_dash_length
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "dash_length"), "set_dash_length", "get_dash_length");

		ClassDB::bind_method(
			D_METHOD("set_dash_time", "dash_time"), 
			&StandardRigidBodyController::set_dash_time
		);
		ClassDB::bind_method(
			D_METHOD("get_dash_time"), 
			&StandardRigidBodyController::get_dash_time
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "dash_time"), "set_dash_time", "get_dash_time");

		ClassDB::bind_method(
			D_METHOD("set_dash_buffer_time", "dash_buffer_time"), 
			&StandardRigidBodyController::set_dash_buffer_time
		);
		ClassDB::bind_method(
			D_METHOD("get_dash_buffer_time"), 
			&StandardRigidBodyController::get_dash_buffer_time
		);
		ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "dash_buffer_time"), "set_dash_buffer_time", "get_dash_buffer_time");
	}
};
