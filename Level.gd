class_name Level
extends Node

@export var title : String
@export var day_length : float = 60.0

var level_time : float

var time_of_day : float:
	get:
		var days : float = level_time / day_length
		return days - floor(days)

func _ready():
	LevelManager.register_level(self)


func _process(delta:float):
	level_time += delta * Engine.time_scale
