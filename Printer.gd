class_name Printer
extends Node3D

@export var radius : float = 0.1
@export var color : Color

func apply_print():
	LevelManager.current_level.paint_map.draw_circle(global_position, radius,color,PaintMap.BlendMode.BLEND)
	LevelManager.current_level.paint_map.draw_circle(global_position+global_basis.z*0.1, radius,color,PaintMap.BlendMode.BLEND)
