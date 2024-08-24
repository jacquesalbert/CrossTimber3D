extends Node

var current_level : Level

func register_level(level:Level):
	current_level = level

func spawn_in_level(node:Node):
	if is_instance_valid(current_level):
		current_level.add_child(node)
