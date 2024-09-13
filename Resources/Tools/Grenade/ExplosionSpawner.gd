class_name ExplosionSpawner
extends Spawner

var responsible_node : Node

func set_responsible_node(node:Node):
	responsible_node = node

func _ready() -> void:
	super._ready()
	if instance is Explosion:
		instance.set_responsible_node(responsible_node)
