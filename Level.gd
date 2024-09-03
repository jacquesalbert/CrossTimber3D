class_name Level
extends Node

@export var title : String
@export var day_length : float = 120.0
@export_range(0.0,1.0) var start_time : float = 0.5
@export var sun_light : DirectionalLight3D
@export var world_environment : WorldEnvironment
@export var sky_time_gradient : Gradient
@export var day_intensity : float = 1.0
@export var night_intensity : float = 0.5

var level_time : float

var time_of_day : float:
	get:
		var days : float = level_time / day_length
		return days - floor(days)

func _ready():
	LevelManager.register_level(self)
	level_time += day_length * start_time


func _process(delta:float):
	level_time += delta
	update_light()

func update_light():
	var relative_intensity :float= max(sin((time_of_day-0.25)*TAU),0.0)
	#print(snappedf(time_of_day,0.01), " ", snappedf(relative_intensity,0.01))
	var intensity := relative_intensity * day_intensity + night_intensity

	sun_light.light_energy = intensity
	world_environment.environment.sky.sky_material.energy_multiplier = intensity
	world_environment.environment.sky.sky_material.sky_top_color = sky_time_gradient.sample(time_of_day)
	#sun_light.rotation.y = lerp(-deg_to_rad(45),deg_to_rad(45),time_of_day*2)
