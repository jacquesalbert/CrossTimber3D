class_name Explosion
extends Node3D

var responsible_node : Node
@export var shrapnel_firer : BulletFirer
@export var blast_area : BlastArea

func set_responsible_node(node:Node):
	responsible_node = node
	shrapnel_firer.responsible_node = responsible_node
	blast_area.responsible_node = responsible_node
