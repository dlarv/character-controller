#pragma once
#define BIND_PROP(n, s, g, t, ...) \
	ClassDB::bind_method(D_METHOD("set_" n, n), &StandardRigidBodyController::s); \
	ClassDB::bind_method(D_METHOD("get_" n), &StandardRigidBodyController::g); \
	ADD_PROPERTY(PropertyInfo(t, n __VA_OPT__(,) __VA_ARGS__), "set_" n, "get_" n);
#define BIND_PROP_HIDE(n, s, g, t) \
	ClassDB::bind_method(D_METHOD("set_" n, n), &StandardRigidBodyController::s);\
	ClassDB::bind_method(D_METHOD("get_" n), &StandardRigidBodyController::g); \
	ADD_PROPERTY(PropertyInfo(t, n, PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NONE), "set_" n, "get_" n);
#define GET_SET(n, t) void set_ ## n(t p) { n = p; }\
	t get_ ## n() const { return n; }
#define BIND_CONST(n, g, t) \
	ClassDB::bind_method(D_METHOD("get_" n), &StandardRigidBodyController::g); \
	ADD_PROPERTY(PropertyInfo(t, n, PROPERTY_HINT_NONE, "", PROPERTY_USAGE_READ_ONLY), "", "get_" n);

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
	bool is_on_floor = true;
	double h_speed;
	double v_speed;
	bool is_walking = false;
	bool is_sprinting = false;
	bool is_jumping = false;
	bool is_dashing = false;
	bool is_heavy_fall = false;
	bool can_sprint = true;
	bool can_jump = true;
	bool can_dash = true;
	Vector3 last_facing_direction;

public:
	/* CONSTANTS */
	const StringName WALK_KEY = "walk";
	const StringName SPRINT_KEY = "sprint";
	const StringName JUMP_KEY = "jump";
	const StringName DASH_KEY = "dash";
	static const int DEFAULT_CONTACTS_REPORTED = 100;

	StringName get_walk_key() const { return WALK_KEY; }
	StringName get_sprint_key() const { return SPRINT_KEY; }
	StringName get_jump_key() const { return JUMP_KEY; }
	StringName get_dash_key() const { return DASH_KEY; }

	/* (DE)CONSTRUCTOR */
	StandardRigidBodyController() = default;
	~StandardRigidBodyController() override = default;

	/* METHODS */
	bool enable_ability(StringName key, bool enabled);
	TypedArray<StringName> enable_abilities(TypedArray<StringName> key, bool enabled);
	bool refresh_ability(StringName key, bool enabled);
	TypedArray<StringName> refresh_abilities(TypedArray<StringName> key, bool enabled);
	bool grant_ability(StringName key, bool enabled);
	Dictionary get_state_data();

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
	void set_is_walking(const bool p) { is_walking = p; }
	bool get_is_walking() const { return is_walking; }
	void set_is_sprinting(const bool p) { is_sprinting = p; }
	bool get_is_sprinting() const { return is_sprinting; }
	void set_is_jumping(const bool p) { is_jumping = p; }
	bool get_is_jumping() const { return is_jumping; }
	void set_is_dashing(const bool p) { is_dashing = p; }
	bool get_is_dashing() const { return is_dashing; }
	void set_is_on_floor(const bool p) { is_on_floor = p; }
	bool get_is_on_floor() const { return is_on_floor; }
	void set_h_speed(const double p) { h_speed = p; }
	double get_h_speed() const { return h_speed; }
	void set_v_speed(const double p) { v_speed = p; }
	double get_v_speed() const { return v_speed; }
	void set_is_heavy_fall(const bool p) { is_heavy_fall = p; }
	bool get_is_heavy_fall() const { return is_heavy_fall; }
	void set_can_sprint(const bool p) { can_sprint = p; }
	bool get_can_sprint() const { return can_sprint; }
	void set_can_jump(const bool p) { can_jump = p; }
	bool get_can_jump() const { return can_jump; }
	void set_can_dash(const bool p) { can_dash = p; }
	bool get_can_dash() const { return can_dash; }
	void set_last_facing_direction(const Vector3 p) { last_facing_direction = p; }
	Vector3 get_last_facing_direction() const { return last_facing_direction; }

protected:
static void _bind_methods() {
	ADD_SIGNAL(MethodInfo("state_started", PropertyInfo(Variant::STRING_NAME, "key")));
	ADD_SIGNAL(MethodInfo("state_finished", PropertyInfo(Variant::STRING_NAME, "key")));
	ADD_SIGNAL(MethodInfo("ability_granted", PropertyInfo(Variant::STRING_NAME, "key")));

	// CONSTANTS
	BIND_CONSTANT(DEFAULT_CONTACTS_REPORTED);
	// BIND_CONST("WALK_KEY", get_walk_key, Variant::STRING_NAME);
	// BIND_CONST("SPRINT_KEY", get_sprint_key, Variant::STRING_NAME);
	// BIND_CONST("DASH_KEY", get_dash_key, Variant::STRING_NAME);
	// BIND_CONST("JUMP_KEY", get_jump_key, Variant::STRING_NAME);

	// PUBLIC METHODS
	ClassDB::bind_method(D_METHOD("enable_ability"), &StandardRigidBodyController::enable_ability);
	ClassDB::bind_method(D_METHOD("enable_abilities"), &StandardRigidBodyController::enable_abilities);
	ClassDB::bind_method(D_METHOD("refresh_ability"), &StandardRigidBodyController::refresh_ability);
	ClassDB::bind_method(D_METHOD("refresh_abilities"), &StandardRigidBodyController::refresh_abilities);
	ClassDB::bind_method(D_METHOD("grant_ability"), &StandardRigidBodyController::grant_ability);
	ClassDB::bind_method(D_METHOD("get_state_data"), &StandardRigidBodyController::get_state_data);

	// BASIC PHYSICS PROPERTIES
	BIND_PROP("grounded_damping", set_grounded_damping, get_grounded_damping, Variant::VECTOR3);
	BIND_PROP("ungrounded_damping", set_ungrounded_damping, get_ungrounded_damping, Variant::VECTOR3);
	BIND_PROP("floor_normal_threshold", set_floor_normal_threshold, get_floor_normal_threshold, Variant::FLOAT, PROPERTY_HINT_RANGE, "0,1");
	BIND_PROP("floor_collision_layer", set_floor_collision_layer, get_floor_collision_layer, Variant::INT, PROPERTY_HINT_LAYERS_3D_PHYSICS);
	BIND_PROP("falling_gravity_mod", set_falling_gravity_mod, get_falling_gravity_mod, Variant::FLOAT, PROPERTY_HINT_RANGE, "0.01,1000");
	BIND_PROP("falling_threshold", set_falling_threshold, get_falling_threshold, Variant::FLOAT);
	BIND_PROP("heavy_fall_threshold", set_heavy_fall_threshold, get_heavy_fall_threshold, Variant::FLOAT);
	BIND_PROP("heavy_fall_wait_time", set_heavy_fall_wait_time, get_heavy_fall_wait_time, Variant::FLOAT);

	// WALKING PROPERTIES
	BIND_PROP("walk_speed", set_walk_speed, get_walk_speed, Variant::FLOAT);
	BIND_PROP("move_left_action", set_move_left_action, get_move_left_action, Variant::STRING, PROPERTY_HINT_INPUT_NAME, "show_builtin");
	BIND_PROP("move_right_action", set_move_right_action, get_move_right_action, Variant::STRING, PROPERTY_HINT_INPUT_NAME, "show_builtin");
	BIND_PROP("move_up_action", set_move_up_action, get_move_up_action, Variant::STRING, PROPERTY_HINT_INPUT_NAME, "show_builtin");
	BIND_PROP("move_down_action", set_move_down_action, get_move_down_action, Variant::STRING, PROPERTY_HINT_INPUT_NAME, "show_builtin");

	// SPRINTING PROPERTIES
	ADD_GROUP("Sprint", "");
	BIND_PROP("sprint_enabled", set_sprint_enabled, get_sprint_enabled, Variant::BOOL, PROPERTY_HINT_GROUP_ENABLE);
	BIND_PROP("sprint_action", set_sprint_action, get_sprint_action, Variant::STRING, PROPERTY_HINT_INPUT_NAME, "show_builtin");
	BIND_PROP("sprint_speed", set_sprint_speed, get_sprint_speed, Variant::FLOAT);
	BIND_PROP("sprint_toggle_mode", set_sprint_toggle_mode, get_sprint_toggle_mode, Variant::BOOL);

	// JUMPING  PROPERTIES
	ADD_GROUP("Jump", "");
	BIND_PROP("jump_enabled", set_jump_enabled, get_jump_enabled, Variant::BOOL, PROPERTY_HINT_GROUP_ENABLE);
	BIND_PROP("jump_action", set_jump_action, get_jump_action, Variant::STRING, PROPERTY_HINT_INPUT_NAME, "show_builtin");
	BIND_PROP("jump_height", set_jump_height, get_jump_height, Variant::FLOAT);
	BIND_PROP("coyote_time", set_coyote_time, get_coyote_time, Variant::FLOAT);
	BIND_PROP("variable_jump_frames", set_variable_jump_frames, get_variable_jump_frames, Variant::INT);
	BIND_PROP("variable_jump_amount", set_variable_jump_amount, get_variable_jump_amount, Variant::FLOAT);
	BIND_PROP("jump_buffer_time", set_jump_buffer_time, get_jump_buffer_time, Variant::FLOAT);

	// DASHING PROPERTIES
	ADD_GROUP("Dash", "");
	BIND_PROP("dash_enabled", set_dash_enabled, get_dash_enabled, Variant::BOOL, PROPERTY_HINT_GROUP_ENABLE);
	BIND_PROP("dash_action", set_dash_action, get_dash_action, Variant::STRING, PROPERTY_HINT_INPUT_NAME, "show_builtin");
	BIND_PROP("dash_length", set_dash_length, get_dash_length, Variant::FLOAT);
	BIND_PROP("dash_time", set_dash_time, get_dash_time, Variant::FLOAT);
	BIND_PROP("dash_buffer_time", set_dash_buffer_time, get_dash_buffer_time, Variant::FLOAT);

	// ANIMATION/ETC HELPER VARS
	BIND_PROP_HIDE("is_sprinting", set_is_sprinting, get_is_sprinting, Variant::BOOL);
	BIND_PROP_HIDE("is_walking", set_is_walking, get_is_walking, Variant::BOOL);
	BIND_PROP_HIDE("is_jumping", set_is_jumping, get_is_jumping, Variant::BOOL);
	BIND_PROP_HIDE("is_dashing", set_is_dashing, get_is_dashing, Variant::BOOL);
	BIND_PROP_HIDE("is_on_floor", set_is_on_floor, get_is_on_floor, Variant::BOOL);
	BIND_PROP_HIDE("v_speed", set_v_speed, get_v_speed, Variant::FLOAT);
	BIND_PROP_HIDE("h_speed", set_h_speed, get_h_speed, Variant::FLOAT);
	BIND_PROP_HIDE("is_heavy_fall", set_is_heavy_fall, get_is_heavy_fall, Variant::BOOL);
	BIND_PROP_HIDE("can_sprint", set_can_sprint, get_can_sprint, Variant::BOOL);
	BIND_PROP_HIDE("can_jump", set_can_jump, get_can_jump, Variant::BOOL);
	BIND_PROP_HIDE("can_dash", set_can_dash, get_can_dash, Variant::BOOL);
	BIND_PROP_HIDE("can_dash", set_can_dash, get_can_dash, Variant::VECTOR3);
	BIND_PROP_HIDE("last_facing_direction", set_last_facing_direction, get_last_facing_direction, Variant::VECTOR3);
}
};
