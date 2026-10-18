#include "standard_rigid_body_controller.h"

bool StandardRigidBodyController::enable_ability(StringName key, bool enabled){
	return false;
}
TypedArray<StringName> StandardRigidBodyController::enable_abilities(TypedArray<StringName> key, bool enabled){
	return key;
}
bool StandardRigidBodyController::refresh_ability(StringName key, bool enabled){
	return false;
}
TypedArray<StringName> StandardRigidBodyController::refresh_abilities(TypedArray<StringName> key, bool enabled){
	return key;
}
bool StandardRigidBodyController::grant_ability(StringName key, bool enabled){
	return false;
}
Dictionary StandardRigidBodyController::get_state_data() {
	Dictionary dict;
	return dict;
}
