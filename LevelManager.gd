extends Node

var current_level : Level

func register_level(level:Level):
	current_level = level

func spawn_in_level(node:Node):
	if is_instance_valid(current_level):
		current_level.add_child(node)

func spawn_hit_effect_in_level(global_pos:Vector3, direction:Vector3, normal:Vector3, effect:PackedScene):
	if is_instance_valid(effect):
		var hit_effect_instance := effect.instantiate()
		hit_effect_instance.rotation.y = normal.signed_angle_to(Vector3.BACK,Vector3.DOWN)
		hit_effect_instance.position = global_pos
		spawn_in_level(hit_effect_instance)
