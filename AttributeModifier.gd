class_name AttributeModifier
extends Resource

@export var overrides : Dictionary
@export var multiply_modifiers : Dictionary
@export var add_modifiers : Dictionary

func override_value(attribute:StringName,value):
	if overrides.has(attribute):
		return overrides[attribute]
	return value

func modify_multiply(attribute:StringName,value):
	if multiply_modifiers.has(attribute):
		return value * multiply_modifiers[attribute]
	return value

func modify_addition(attribute:StringName,value):
	if add_modifiers.has(attribute):
		return value + add_modifiers[attribute]
	return value
