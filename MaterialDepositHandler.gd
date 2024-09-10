class_name MaterialDepositHandler
extends Node

var current_material : NodeMaterial
var deposit_material : NodeMaterial
var deposit_remaining : float

var _prev_position : Vector3
var parent : Node3D

signal material_changed(new_material:NodeMaterial)

func get_effective_material()->NodeMaterial:
	if is_instance_valid(deposit_material):
		return deposit_material
	return current_material

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	_prev_position = parent.global_position

func set_base_material(new_material:NodeMaterial):
	var prev_material := get_effective_material()
	if is_instance_valid(new_material):
		if new_material.deposit_distance > 0.0:
			deposit_material = new_material
			deposit_remaining = new_material.deposit_distance
	current_material = new_material
	if get_effective_material() != prev_material:
		material_changed.emit(get_effective_material())
		
	

func _physics_process(delta: float) -> void:
	if deposit_remaining > 0.0:
		var distance_travelled := (parent.global_position - _prev_position).length()
		deposit_remaining -= distance_travelled
		if deposit_remaining <= 0.0:
			deposit_material = null
			deposit_remaining = 0.0
			material_changed.emit(current_material)
			
	_prev_position = parent.global_position
