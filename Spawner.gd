class_name Spawner
extends Node3D

@export var spawn_scene : PackedScene
var instance : Node

func _ready() -> void:
	instance = spawn_scene.instantiate()

func spawn():
	instance.position = global_position
	LevelManager.spawn_in_level(instance)
