class_name Bullet
extends RayCast3D

@export var speed : float = 10
@export var speed_variation : float = 0.0
@export var speed_minimum : float = 50.0

@export var damage : int = 10
@export var damage_variation : float = 0.0
@export var damage_minimum : float = 0.0

@export var range : float = 100
@export var range_variation : float = 0.0
@export var range_minimum : float = 0.0

@export var stability : float = 0.95

@export var apply_effects: Array[PackedScene]
@export var material_hit_effects: Dictionary

var responsible_node : Node
#var direction : Vector3 = Vector3.FORWARD
var _noise : Noise

var total_travelled : float
var last_pos : Vector3

var _range : float
var _local_velocity : Vector3

#func _init(direction:Vector3, speed:float, stability:float, damage:int, range:float, responsible_node:Node, mask:int):
	#self.direction = direction
	#self.speed = speed
	#self.stability = stability
	#self.damage = damage
	#self.range = range
	#self.responsible_node = responsible_node
	#collision_mask = mask

# Called when the node enters the scene tree for the first time.
func _ready():
	_noise = FastNoiseLite.new()
	_noise.frequency = 1
	
	var initial_speed :float= max(speed_minimum,randfn(speed, speed_variation))
	_range = max(range_minimum,randfn(range, range_variation))
	_local_velocity = Vector3.MODEL_FRONT * initial_speed
	
	collide_with_areas = true
	last_pos = position
	set_next_target_position(Engine.time_scale/Engine.physics_ticks_per_second)

func set_next_target_position(delta:float):
	#var forward := -global_basis.z
	#if is_instance_valid(trail):
		#trail.update_points(global_position)
	var travel := _local_velocity * delta
	total_travelled += travel.length()
	if total_travelled > _range:
		var excess_travel := total_travelled - _range
		travel = _local_velocity * (travel.length() - excess_travel)  * delta
	target_position = travel

func _physics_process(delta):
	#var forward := -global_basis.z
	#var effect_material :EffectMaterial
	# first see if we have collided with anything
	var stop : bool = false
	var frame_travel_finished := false
	var end_position : Vector3 = position + target_position
	var frame_exceptions : Array[CollisionObject3D]
	while not frame_travel_finished:
		if is_colliding():
			var collider := get_collider()
			var collision_point := get_collision_point()
			var spawn_effect := false
			var recalc := false
			if collider is Hitbox:
				var hitbox: Hitbox = collider
				var hitbox_result := hitbox.hit(-damage, responsible_node)
				#print_debug(hitbox_result)
				if hitbox_result['hit']:
					spawn_effect = true
					for effect_scene in apply_effects:
						var effect := effect_scene.instantiate()
						effect.responsible_node = responsible_node
						hitbox.get_parent().add_child(effect)
				
					
					#if hitbox_result.has('penetration_modify'):
						#penetration = max(0,penetration - hitbox_result['penetration_modify'])
					if hitbox_result.has('stability_modify'):
						stability = max(0,stability + hitbox_result['stability_modify'])
					if hitbox_result.has('damage_modify'):
						damage = max(0,damage + hitbox_result['damage_modify'])
					if damage == 0:
						stop = true
						frame_travel_finished = true
						end_position = collision_point
					else:
						frame_exceptions.append(hitbox)
						add_exception(hitbox)
						recalc = true

				else:
					spawn_effect = false
					frame_exceptions.append(hitbox)
					add_exception(hitbox)
					recalc = true
			else:
				spawn_effect = true
				stop = true
				frame_travel_finished = true
				end_position = collision_point
			
			if recalc:
				force_raycast_update()
			
			if spawn_effect:
				var effect_material = NodeMaterial.get_collision_shape_material(collider,get_collider_shape())
				var hit_normal := get_collision_normal()
				LevelManager.spawn_hit_effect_in_level(collision_point, global_basis*Vector3.MODEL_FRONT, hit_normal,material_hit_effects.get(effect_material)) # _direction.bounce(get_collision_normal()).angle()
				if not stop:
					LevelManager.spawn_hit_effect_in_level(collision_point, global_basis*Vector3.MODEL_FRONT, global_basis*Vector3.MODEL_FRONT,material_hit_effects.get(effect_material)) # _direction.bounce(get_collision_normal()).angle()
		else:
			frame_travel_finished = true
	for exception in frame_exceptions:
		remove_exception(exception)
	frame_exceptions.clear()
	
	if total_travelled >= range:
		var excess_travel := total_travelled - range
		stop = true
	
	if stop:
		position = end_position
		queue_free()
		return
	
	
	# if we didn't hit anything, advance our position. Be careful to check that we don't extend the ray further than the total distance
	last_pos = position
	position += global_basis * target_position 
	print("set tumble")
	#var tumble_angle : float= _noise.get_noise_2dv(global_position)*PI * (1.0 - stability) * 10 * delta
	#direction = direction.rotated(tumble_angle)
	set_next_target_position(delta)
