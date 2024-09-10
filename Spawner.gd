class_name Spawner
extends Node3D

@export var spawn_scene : PackedScene

func spawn():
	var instance := spawn_scene.instantiate()
	instance.position = global_position
	LevelManager.spawn_in_level(instance)
