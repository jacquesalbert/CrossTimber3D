class_name Explosion
extends Node3D

@export_flags_3d_physics var hit_layers : int
@export_flags_3d_physics var block_layers : int
@export var damage : int = 100
@export var damage_falloff : Curve
@export var impulse : float = 5
@export var impulse_falloff : Curve
@export var radius : float = 30
@export var queue_explode : bool

var responsible_node : Node

signal exploded

func explode():
	var sphere_query := PhysicsShapeQueryParameters3D.new()
	sphere_query.collide_with_areas = true
	var shape := SphereShape3D.new()
	shape.radius = radius
	sphere_query.shape = shape
	sphere_query.collision_mask = hit_layers
	sphere_query.transform = global_transform
	var sphere_query_results := get_world_3d().direct_space_state.intersect_shape(sphere_query)
	
	for result in sphere_query_results:
		var area : CollisionObject3D = result['collider']
		if area is Hitbox:
			var query := PhysicsRayQueryParameters3D.create(global_position,area.global_position,block_layers)
			var query_result := get_world_3d().direct_space_state.intersect_ray(query)
			if query_result.size() > 0:
				continue
			var distance := (global_position-area.global_position).length()
			var relative_distance := distance / radius
			var damage_float :float= damage*damage_falloff.sample(relative_distance) if damage_falloff else damage
			var damage :int = roundi(damage_float)
			area.hit(-damage,responsible_node)
	push_bodies.call_deferred()
	exploded.emit()

func push_bodies():
	var sphere_query := PhysicsShapeQueryParameters3D.new()
	sphere_query.collide_with_areas = true
	var shape := SphereShape3D.new()
	shape.radius = radius
	sphere_query.shape = shape
	sphere_query.collision_mask = hit_layers
	sphere_query.transform = global_transform
	var sphere_query_results := get_world_3d().direct_space_state.intersect_shape(sphere_query)
	
	for result in sphere_query_results:
		var body : CollisionObject3D = result['collider']
		if body is RigidBody3D:
			var query := PhysicsRayQueryParameters3D.create(global_position,body.global_position,block_layers)
			var query_result := get_world_3d().direct_space_state.intersect_ray(query)
			if query_result.size() > 0:
				continue
			var vector_to_body := body.global_position - global_position
			var relative_distance := vector_to_body.length() / radius
			var impulse :float= impulse*impulse_falloff.sample(relative_distance) if impulse_falloff else impulse
			
			body.apply_central_impulse(vector_to_body.normalized() * impulse)

func _physics_process(delta:float):
	if queue_explode:
		explode()
		queue_explode = false
		queue_free()
		return
	
	
