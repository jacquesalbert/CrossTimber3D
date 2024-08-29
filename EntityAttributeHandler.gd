class_name EntityAttributeHandler
extends Node

@export var attributes : AttributePackage

signal attributes_changed

var modifiers : Array[AttributeModifier]

func get_attribute_value(attribute:StringName):
	return apply_modifiers(attributes.get_base_value(attribute),attribute)

func add_modifier(modifier:AttributeModifier):
	modifiers.append(modifier)
	attributes_changed.emit()

func remove_modifier(modifier:AttributeModifier):
	modifiers.erase(modifier)
	attributes_changed.emit()

func apply_modifiers(value,attribute:StringName):
	var new_value = value
	for modifier in modifiers:
		new_value = modifier.modify_multiply(attribute,new_value)
	for modifier in modifiers:
		new_value = modifier.modify_addition(attribute,new_value)
	for modifier in modifiers:
		new_value = modifier.override_value(attribute,new_value)
	return new_value
