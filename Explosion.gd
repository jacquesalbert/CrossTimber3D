class_name Explosion
extends Node2D

@export_flags_2d_physics var hit_layers : int
@export_flags_2d_physics var block_layers : int
@export var damage : int = 100
@export var damage_falloff : Curve
@export var radius : float = 30
@export var queue_explode : bool

var responsible_node : Node

signal exploded

func explode():
	var circle_query := PhysicsShapeQueryParameters2D.new()
	circle_query.collide_with_areas = true
	var shape := CircleShape2D.new()
	shape.radius = radius
	circle_query.shape = shape
	circle_query.collision_mask = hit_layers
	circle_query.transform = Transform2D(0,global_position)
	var circle_query_results := get_world_2d().direct_space_state.intersect_shape(circle_query)
	
	for result in circle_query_results:
		var area : CollisionObject2D = result['collider']
		if area is Hitbox:
			var query := PhysicsRayQueryParameters2D.create(global_position,area.global_position,block_layers)
			var query_result := get_world_2d().direct_space_state.intersect_ray(query)
			if query_result.size() > 0:
				continue
			var distance := (global_position-area.global_position).length()
			var relative_distance := distance / radius
			var damage_float :float= damage*damage_falloff.sample(relative_distance) if damage_falloff else damage
			var damage :int = roundi(damage_float)
			area.hit(-damage,responsible_node)
	exploded.emit()

func _physics_process(delta:float):
	if queue_explode:
		explode()
		queue_explode = false
		queue_free()
		return
	
	
