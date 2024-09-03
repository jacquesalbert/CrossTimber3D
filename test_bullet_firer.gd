extends Node3D

@export var firearm_scene : PackedScene

var tool : ToolInstance
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tool = firearm_scene.instantiate()
	add_child(tool)
	tool.trigger()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
