class_name Bullet
extends RayCast3D

@export var speed : float = 10
@export var damage : int = 10
@export var range : float = 100
#@export var penetration : float = 1.0
@export var stability : float = 0.95
#@export var material_effect_definition :MaterialEffectDefinition
#@export_flags_2d_physics var ground_area_mask :int
#@export var trail_template: PackedScene
#@export var trail_gradient : Gradient
#@export var trail_lifetime : float
#@export var trail_width : float
#@export var trail_width_curve : Curve
#@export var trail_color : Color
#@export var trail_shadow : GeometryInstance3D.ShadowCastingSetting
#@export var trail_transparency : BaseMaterial3D.Transparency

@export var apply_effects: Array[PackedScene]
@export var material_hit_effects: Dictionary

var responsible_node : Node
#var delta : float = .02
var direction : Vector3 = Vector3.FORWARD
var noise : Noise

var total_travelled : float
var last_pos : Vector3

#var trailer : Trailer

func _init(direction:Vector3, speed:float, stability:float, damage:int, range:float, responsible_node:Node, mask:int):
	self.direction = direction
	self.speed = speed
	self.stability = stability
	self.damage = damage
	self.range = range
	self.responsible_node = responsible_node
	#self.trail_gradient = trail_gradient
	#self.trail_lifetime = trail_lifetime
	#self.trail_width = trail_width
	collision_mask = mask
	
#var trail:Trail

func spawn_hit_effect(global_pos:Vector3, direction:Vector3, normal:Vector3, effect_material:EffectMaterial):
	var effect : PackedScene = material_hit_effects.get(effect_material)
	if effect:
		var hit_effect_instance := effect.instantiate()
		hit_effect_instance.rotation.y = normal.signed_angle_to(Vector3.BACK,Vector3.DOWN)
		hit_effect_instance.position = global_pos
		LevelManager.spawn_in_level(hit_effect_instance)

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("create")
	noise = FastNoiseLite.new()
	noise.frequency = 1
	#trailer = Trailer.new()
	#trailer.gradient = trail_gradient
	#trailer.width = trail_width
	#trailer.color = trail_color
	#trailer.width_curve = trail_width_curve
	#trailer.lifetime = trail_lifetime
	#trailer.cast_shadow = trail_shadow
	#trailer.transparency = trail_transparency
	#add_child(trailer)
	#trailer.enable()
	collide_with_areas = true
	last_pos = global_position
	set_next_target_position(Engine.time_scale/Engine.physics_ticks_per_second)

#func fire(direction:Vector2, responsible_node:Node, delta:float):
	#self.responsible_node = responsible_node
	#self.direction = direction
	#self.delta = delta
	
	

func set_next_target_position(delta:float):
	#if is_instance_valid(trail):
		#trail.update_points(global_position)
	var travel := direction * speed * delta
	total_travelled += travel.length()
	if total_travelled > range:
		var excess_travel := total_travelled - range
		travel = direction * (travel.length() - excess_travel)
	target_position = travel

func _physics_process(delta):
	#var effect_material :EffectMaterial
	# first see if we have collided with anything
	var stop : bool = false
	var frame_travel_finished := false
	var end_position : Vector3 = global_position + target_position
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
				var effect_material = EffectMaterial.get_collision_shape_material(collider,get_collider_shape())
				var hit_normal := get_collision_normal()
				spawn_hit_effect(collision_point, self.direction, hit_normal,effect_material) # _direction.bounce(get_collision_normal()).angle()
			
			#if trail and is_instance_valid(trail):
				#trail.update_points(collision_point)
		else:
			frame_travel_finished = true
	for exception in frame_exceptions:
		remove_exception(exception)
	frame_exceptions.clear()
	
	if total_travelled >= range:
		var excess_travel := total_travelled - range
		stop = true
	
	if stop:
		global_position = end_position
		queue_free()
		return
	
	
	# if we didn't hit anything, advance our position. Be careful to check that we don't extend the ray further than the total distance
	last_pos = global_position
	global_position += target_position
	#print("set tumble")
	#var tumble_angle : float= noise.get_noise_2dv(global_position)*PI * (1.0 - stability) * 10 * delta
	#direction = direction.rotated(tumble_angle)
	set_next_target_position(delta)
