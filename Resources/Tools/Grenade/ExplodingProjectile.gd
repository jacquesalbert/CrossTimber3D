class_name ExplodingProjectile
extends SimpleProjectile

@export var explosion_spawner : ExplosionSpawner

func set_responsible_node(node:Node):
	super.set_responsible_node(node)
	explosion_spawner.set_responsible_node(node)
