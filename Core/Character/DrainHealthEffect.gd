extends Effect

@export var damage : int

var responsible_node : Node

func _enter_tree():
	super._enter_tree()
	var parent := get_parent()
	if is_instance_valid(parent) and parent.has_method("get_emission_texture") and parent.has_method("get_emission_points"):
		var emission_texture :ImageTexture = parent.get_emission_texture()
		var emission_points :int = parent.get_emission_points()
		for child in get_children():
			if child is GPUParticles2D:
				var process_material : ParticleProcessMaterial = child.process_material
				process_material.emission_point_texture = emission_texture
				process_material.emission_point_count = emission_points
				child.amount = max(8,emission_points * 0.05)

func drain_health():
	var parent := get_parent()
	if parent is Character:
		if parent.health.value > 0:
			parent.health.modify(-damage,responsible_node)
