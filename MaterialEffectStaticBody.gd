class_name MaterialEffectStaticBody
extends StaticBody3D

@export var effect_material : StringName
@export var traction : float = 1.0

func get_effect_material()->StringName:
	return effect_material

func get_traction()->float:
	return traction
