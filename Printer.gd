class_name Printer
extends Node3D

@export var radius : float = 1.0
@export var color : Color

func apply_print():
	LevelManager.current_level.paint_map.set_circle(global_position, radius,color)
	LevelManager.current_level.paint_map.set_circle(global_position+global_basis.z*0.1, radius,color)
