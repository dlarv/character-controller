#include "standard_rigid_body_controller.h"

void StandardRigidBodyController::_bind_methods() {
	ClassDB::bind_method(
		D_METHOD("set_typed_array", "typed_array"), 
		&StandardRigidBodyController::set_typed_array
	);
	ClassDB::bind_method(
		D_METHOD("get_typed_array"), 
		&StandardRigidBodyController::get_typed_array
	);
	ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "typed_array"), "set_typed_array", "get_typed_array");

	ClassDB::bind_method(
		D_METHOD("set_value", "value"), 
		&StandardRigidBodyController::set_value
	);
	ClassDB::bind_method(
		D_METHOD("get_value"), 
		&StandardRigidBodyController::get_value
	);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "value"), "set_value", "get_value");

}

