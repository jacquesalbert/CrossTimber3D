class_name AttributePackage
extends Resource

@export var attribute_base_values : Dictionary

func get_base_value(attribute:StringName):
	return attribute_base_values[attribute]

func get_attributes()->Array[StringName]:
	return attribute_base_values.keys()
