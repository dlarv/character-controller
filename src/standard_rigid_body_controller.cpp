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
TypedArray<StringName> StandardRigidBodyController::enable_abilities(TypedArray<StringName> key, bool enabled){
	return key;
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
TypedArray<StringName> StandardRigidBodyController::refresh_abilities(TypedArray<StringName> key, bool enabled){
	return key;
}
bool StandardRigidBodyController::grant_ability(StringName key, bool enabled){
	emit_signal("ability_granted", key);
	return SRBC::enable_ability(key, enabled);
}
Dictionary StandardRigidBodyController::get_state_data() {
	Dictionary dict;
	return dict;
}
