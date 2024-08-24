class_name CharacterAttributes
extends Node

@export var base_speed : float = 18.0
@export var base_can_run : bool = true
@export var base_inventory_size : float = 1.0
@export var base_vision_range : float = 100.0
@export var base_field_of_view : float = deg_to_rad(60.0)
@export var base_hearing_threshold : float = 1.0
@export var base_health : int = 100
@export var base_energy : int = 100
@export var base_run_modifier : float = 2.0
@export var base_turn_speed : float = 15.0
@export var base_acceleration : float = 1000.0
@export var base_accuracy : float = 0.05
@export var base_inventory_item_capacities : Dictionary

signal attributes_changed

var can_run : bool:
	get:
		return apply_effects(base_can_run,"can_run")

var speed : float:
	get:
		return apply_effects(base_speed,"speed")

var inventory_size : float:
	get:
		return apply_effects(base_inventory_size,"inventory_size")

var vision_range : float:
	get:
		return apply_effects(base_vision_range,"vision_range")

var field_of_view : float:
	get:
		return apply_effects(base_field_of_view,"field_of_view")

var hearing_threshold : float:
	get:
		return apply_effects(base_hearing_threshold,"hearing_threshold")

var health : int:
	get:
		return apply_effects(base_health,"health")

var energy : int:
	get:
		return apply_effects(base_energy,"energy")

var run_modifier : float:
	get:
		return apply_effects(base_run_modifier,"run_modifier")
var turn_speed : float:
	get:
		return apply_effects(base_turn_speed,"turn_speed")
var acceleration : float:
	get:
		return apply_effects(base_acceleration,"acceleration")

var accuracy : float:
	get:
		return apply_effects(base_accuracy,"accuracy")
		
var inventory_max_capacities : Dictionary:
	get:
		var capacities : Dictionary
		for item in base_inventory_item_capacities:
			capacities[item] = _get_inventory_item_capacity(item)
		return capacities

var character : Character
var modifiers : Array[AttributeModifier]

func add_modifier(modifier:AttributeModifier):
	modifiers.append(modifier)
	attributes_changed.emit()

func remove_modifier(modifier:AttributeModifier):
	modifiers.erase(modifier)
	attributes_changed.emit()

func _get_inventory_item_capacity(item:Item)->int:
	return base_inventory_item_capacities.get(item,0) * inventory_size

func apply_effects(value,attribute:StringName):
	var new_value = value
	for modifier in modifiers:
		new_value = modifier.modify_multiply(attribute,new_value)
	for modifier in modifiers:
		new_value = modifier.modify_addition(attribute,new_value)
	for modifier in modifiers:
		new_value = modifier.override_value(attribute,new_value)
	return new_value
