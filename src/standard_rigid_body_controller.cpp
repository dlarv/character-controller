#include "standard_rigid_body_controller.h"
#define SRBC StandardRigidBodyController

bool StandardRigidBodyController::enable_ability(StringName key, bool enabled){
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
TypedArray<StringName> StandardRigidBodyController::enable_abilities(TypedArray<StringName> keys, bool enabled){
	TypedArray<StringName> arr;
	for(const auto& key: keys) {
		if(!SRBC::enable_ability(key, enabled)) {
			arr.push_back(key);
		}
	}
	return arr;
}
bool StandardRigidBodyController::refresh_ability(StringName key, bool enabled){
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
TypedArray<StringName> StandardRigidBodyController::refresh_abilities(TypedArray<StringName> keys, bool enabled){
	TypedArray<StringName> arr;
	for(const auto& key: keys) {
		if(!SRBC::refresh_ability(key, enabled)) {
			arr.push_back(key);
		}
	}
	return arr;
}

bool StandardRigidBodyController::grant_ability(StringName key, bool enabled){
	emit_signal("ability_granted", key);
	return SRBC::enable_ability(key, enabled);
}

Dictionary StandardRigidBodyController::get_state_data() {
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
