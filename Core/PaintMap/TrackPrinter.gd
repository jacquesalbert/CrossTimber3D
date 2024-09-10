class_name TrackPrinter
extends Node3D

@export var color : Color = Color.BLACK
@export var width : float = 0.25
@export_range(0.0,1.0) var strength : float = 0.1

@export var tracking: bool:
	set(value):
		if value != tracking:
			tracking = value
			if tracking:
				enable()
			else:
				disable()

var _prev_position : Vector3

func _ready() -> void:
	_prev_position = global_position
	change_effect_material(null)


func change_effect_material(new_material:NodeMaterial):
	color = new_material.base_color if is_instance_valid(new_material) else Color.TRANSPARENT
	color.a = strength

func enable():
	tracking = true
	add_current_point()

func disable():
	tracking = false

func add_current_point():
	LevelManager.current_level.paint_map.draw_line(global_position, _prev_position,width, color,PaintMap.BlendMode.BLEND)

func _physics_process(delta):
	if tracking:
		add_current_point()
	_prev_position = global_position
