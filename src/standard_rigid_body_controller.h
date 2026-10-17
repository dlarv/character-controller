#pragma once

#include "godot_cpp/core/class_db.hpp"
#include "godot_cpp/classes/wrapped.hpp"
#include "godot_cpp/variant/variant.hpp"
#include "godot_cpp/variant/utility_functions.hpp"

#include <godot_cpp/classes/rigid_body3d.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/templates/vector.hpp>

using namespace godot;

class StandardRigidBodyController: public RigidBody3D {
	GDCLASS(StandardRigidBodyController, RigidBody3D)

private:
		TypedArray<StringName> typed_array;
		int value;


protected:
	static void _bind_methods();

public:
	StandardRigidBodyController() = default;
	~StandardRigidBodyController() override = default;

	bool enable_ability(StringName key, bool enabled);
	TypedArray<StringName> enable_abilities(TypedArray<StringName key>, bool enabled);
	bool refresh_ability(StringName key, bool enabled);
	TypedArray<StringName> refresh_abilities(TypedArray<StringName key>, bool enabled);
	bool grant_ability(StringName key, bool enabled);

	/* GETTERS AND SETTERS */
	void set_typed_array(const TypedArray<StringName> p_array) {
		typed_array = p_array;
	}
	TypedArray<StringName> get_typed_array() const {
		return typed_array;
	}

	void set_value(const int v) {
		UtilityFunctions::print("VALUE = " + v);
		value = v;
	}
	int get_value() const {
		return value;
	}
};
