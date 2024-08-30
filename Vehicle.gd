class_name Vehicle
extends CharacterBody3D

const COLLISION_CONSEVATION : float = 0.5

@export_range(0.0,PI/2) var max_steer_angle : float = PI/8
@export var max_drive_traction_accel : float = 50.0
@export var max_traction_accel : float = 100.0
@export var max_engine_power : float = 100.0
@export var power_curve : Curve
@export var top_speed : float = 400.0
@export var handling_speed : float = 2.0
@export var front_drive : bool
@export var rear_drive : bool
@export var collision_friction : float = 0.5
@export var mass : float = 1500
#@export var ride_height : float = 0.1
@export var rolling_resistance : float = 0.1
@export var fuel_consumpution_rate : float = 1.0
@export var traction_control_modifier : float = 0.8
@export var fuel : Stat
@export var health : Stat

@export var emission_texture : Texture
@export var emission_points : int = 100.0

@export var material_hit_effects : Dictionary

@onready var front_left_wheel := $FLWheel
@onready var front_right_wheel := $FRWheel
@onready var rear_left_wheel := $RLWheel
@onready var rear_right_wheel := $RRWheel

@onready var engine_stream_player := $AudioStreamPlayer2D
@export var start_stream : AudioStream
@export var idle_stream : AudioStream
@export var drive_stream : AudioStream
@export var stop_stream : AudioStream

@onready var door_stream_player := $AudioStreamPlayer2D2


@export var driver_character : Character:
	set(value):
		if driver_character != value:
			if is_instance_valid(door_stream_player):
				door_stream_player.play()
			driver_character = value
			if is_instance_valid(door_stream_player):
				if is_instance_valid(driver_character):
					engine_stream_player.play()
				else:
					engine_stream_player.stop()

var front_axle_distance : float
var rear_axle_distance : float
var wheelbase : float

var angular_speed : float
var fueled : bool = false
var disabled : bool = false
var can_run : bool:
	get:
		return fueled and not disabled
var _fuel_debt : float
var _current_effects : Array[Effect]

signal effects_changed

func _ready():
	front_axle_distance = (front_left_wheel.position.z + front_right_wheel.position.z) * 0.5
	rear_axle_distance = (rear_left_wheel.position.z + rear_right_wheel.position.z) * 0.5
	wheelbase = front_axle_distance - rear_axle_distance

	health.expended.connect(on_health_expended)

func on_health_expended(responsible_node:Node):
	disabled = true

func on_health_restored(responsible_node:Node):
	disabled = false

var throttle : float:
	set(value):
		throttle = clamp(value, -1.0,1.0)

var brake : float:
	set(value):
		brake = clamp(value,0.0,1.0)

var steer : float:
	set(value):
		steer = clamp(value,-1.0,1.0)

var traction_control : bool = true

func get_input_debug():
	steer = Input.get_axis("ui_left","ui_right")
	throttle = Input.get_axis("ui_down","ui_up")
	brake = 1.0 if Input.is_action_pressed("ui_select") else 0.0

func get_input():
	if is_instance_valid(driver_character):
		var controller : Controller = driver_character.controller
		if is_instance_valid(controller):
			steer = controller.steer
			throttle = controller.throttle
			brake = controller.brake
			traction_control = controller.traction_control
	else:
		throttle = 0.0

func _process(delta):
	#get_input_debug()
	get_input()
	update_sounds()

func update_sounds():
	if is_instance_valid(driver_character) and is_instance_valid(engine_stream_player):
		var gear_scale := 2.0
		var speed :float= abs(velocity.dot(global_basis.z))
		var relative_speed := gear_scale * speed / top_speed
		var gear_width := gear_scale * 1.0 / 5.0
		var this_gear_speed :float = floor(relative_speed / gear_width)*gear_width
		var engine_speed := relative_speed - this_gear_speed
		engine_stream_player.pitch_scale = 1.0 + engine_speed if brake < 0.5 else 1.0

func run_fuel(delta:float):
	if can_run:
		_fuel_debt += fuel_consumpution_rate * abs(throttle) * delta
		if _fuel_debt > 1.0 and fuel.value > 0:
			var fuel_consumption_amount : int = floor(_fuel_debt)
			fuel.modify(-fuel_consumption_amount,driver_character)
			_fuel_debt -= fuel_consumption_amount
	fueled = fuel.value > 0

func move_and_handle_collisions(delta:float):
# move and handle collisions
	var remainder : Vector3
	var collision := move_and_collide(velocity*delta)
	var frame_exceptions: Array[CollisionObject2D]
	while collision:
		var collider := collision.get_collider()
		var normal := collision.get_normal()
		var normal_velocity := velocity.dot(normal)
		if collider is Character:
			frame_exceptions.append(collider)
			add_collision_exception_with(collider)
			remainder = collision.get_remainder()
			#collider.request_state = Character.State.KNOCKBACK
			#collider.move_and_collide(normal_velocity*normal*delta)
			if abs(normal_velocity) > 100.0:
				spawn_hit_effect(collision.get_position(),velocity,normal,collider.get_effect_material())
			var damage :int = round(-normal_velocity)
			collider.hitbox.hit(-damage,driver_character)
			collision = move_and_collide(remainder)
			continue
		elif collider is Vehicle:
			if abs(normal_velocity) > 50.0:
				spawn_hit_effect(collision.get_position(),velocity,normal,collider.get_effect_material())
		
			var system_mass :float= collider.mass + mass
			var my_collision_part :float= collider.mass / system_mass
			var my_velocity_change := COLLISION_CONSEVATION * my_collision_part * normal_velocity*normal
			var other_collision_part :float= mass / system_mass
			var other_velocity_change := COLLISION_CONSEVATION * other_collision_part * normal_velocity*normal
			velocity -= my_velocity_change
			collider.velocity += other_velocity_change
			# consider applying torques here eventually
			#var other_relative_point : Vector2= collision.get_position() - collider.global_position
			#var other_torque_vel : float = other_relative_point.cross(other_velocity_change) / collider.mass
			#collider.angular_speed += other_torque_vel
			#var relative_point : Vector2 =collision.get_position() - global_position
			#var torque_vel : float = relative_point.cross(my_velocity_change) / mass
			#angular_speed += torque_vel
			break
		#elif collider is DestructibleBody:
			#frame_exceptions.append(collider)
			#add_collision_exception_with(collider)
			#remainder = collision.get_remainder()
			#collider.impact(normal*normal_velocity)
			#if collider.has_method("get_effect_material") and abs(normal_velocity) > 100.0:
				#spawn_hit_effect(collision.get_position(),velocity,normal,collider.get_effect_material())
			#collision = move_and_collide(remainder)
			#continue
		else:
			if collider.has_method("get_effect_material") and abs(normal_velocity) > 50.0:
				spawn_hit_effect(collision.get_position(),velocity,normal,collider.get_effect_material())
		
			# cancel immovable collision velocity
			velocity -= normal_velocity*normal
			# apply scraping drag on lateral collisions
			var tangent_velocity := -velocity.normalized()
			velocity -= collision_friction * tangent_velocity

			break

	for exception in frame_exceptions:
		remove_collision_exception_with(exception)

func get_speedo()->float:
	return abs(velocity.dot(global_basis.z))

func _physics_process(delta:float):
	#enforce 2D play area
	position.y = 0
	var forward := global_basis.z
	var right := -global_basis.x
	run_fuel(delta)

	var longitudinal_speed := velocity.dot(forward)
	velocity -= forward * longitudinal_speed * rolling_resistance * delta

	var steer_angle := -steer * max_steer_angle
	front_left_wheel.rotation.y = steer_angle
	front_right_wheel.rotation.y = steer_angle
	var rotation_speed :float = (longitudinal_speed / wheelbase) * tan(steer_angle)

	var fl_traction :float= front_left_wheel.traction
	var fr_traction :float= front_right_wheel.traction
	var rl_traction :float= rear_left_wheel.traction
	var rr_traction :float= rear_right_wheel.traction
	var front_traction :float= max(fl_traction,fr_traction)
	var rear_traction :float= max(rl_traction,rr_traction)
	var all_traction : float = max(front_traction,rear_traction)

	# add rotation from steering
	angular_speed = move_toward(angular_speed,rotation_speed, handling_speed* front_traction*delta)
	var steering_lateral_speed := -rear_axle_distance * angular_speed
	# add lateral movement from steering
	global_position += -right * steering_lateral_speed * delta
	# apply angular speed
	global_rotation.y += angular_speed * delta
	
	# cancel lateral movement up to lateral tracking max
	var lateral_movement := velocity.dot(right)
	var lateral_accel := lateral_movement / delta
	

	var spin : float = 0.0
	# apply drive movement up to traction maximum
	#var speed_modifier :float = max(0,(top_speed - abs(longitudinal_speed)) / top_speed)
	var engine_power := power_curve.sample(abs(longitudinal_speed)/top_speed) * max_engine_power if can_run else 0.0
	var drive_accel :float= (throttle * engine_power) - (brake * sign(throttle))
	
	var effective_max_drive_traction_accel : float
	if front_drive and rear_drive:
		effective_max_drive_traction_accel = max_drive_traction_accel * all_traction
	elif front_drive:
		effective_max_drive_traction_accel = max_drive_traction_accel * front_traction
	elif rear_drive:
		effective_max_drive_traction_accel = max_drive_traction_accel * rear_traction

	if abs(drive_accel) > effective_max_drive_traction_accel:
		var excess :float = max(0.0,abs(drive_accel) - effective_max_drive_traction_accel)
		var allowed_excess :float= sign(drive_accel) * excess * (1.0-traction_control_modifier)
		if traction_control:
			drive_accel = sign(drive_accel) * min(abs(drive_accel),effective_max_drive_traction_accel)
			spin = 0.0
		else:
			drive_accel = sign(drive_accel) * min(abs(drive_accel),effective_max_drive_traction_accel) + allowed_excess
			spin = allowed_excess
	if front_drive:
		front_left_wheel.drive_spin = spin
		front_right_wheel.drive_spin = spin
	if rear_drive:
		rear_left_wheel.drive_spin = spin
		rear_right_wheel.drive_spin = spin
	
	velocity += drive_accel * delta * forward
	
	var skid := false
	#apply braking traction
	var braking_acceleration :float = -sign(longitudinal_speed) * (brake * abs(longitudinal_speed)) / delta
	#velocity -= lateral_accel * delta * global_transform.y
	var traction_acceleration := braking_acceleration * forward - lateral_accel * right
	var effective_max_traction_accel := all_traction * max_traction_accel
	var modified_max_traction_acceleration := effective_max_traction_accel if traction_control else effective_max_traction_accel * traction_control_modifier
	if traction_acceleration.length() > modified_max_traction_acceleration:
		skid = true
		traction_acceleration = modified_max_traction_acceleration * traction_acceleration.normalized()
		
	front_left_wheel.traction_slip = skid
	front_right_wheel.traction_slip = skid
	rear_left_wheel.traction_slip = skid
	rear_right_wheel.traction_slip = skid
	
	front_left_wheel.speed = abs(longitudinal_speed)
	front_right_wheel.speed = abs(longitudinal_speed)
	rear_left_wheel.speed = abs(longitudinal_speed)
	rear_right_wheel.speed = abs(longitudinal_speed)
	
	velocity += traction_acceleration * delta
	if velocity.is_zero_approx():
		return
	
	move_and_slide()
	#if is_on_floor():
		#global_position += global_basis.y * ride_height
	#move_and_handle_collisions(delta)

func get_effect_material()->StringName:
	return "metal"

func get_emission_texture():
	return emission_texture

func get_emission_points():
	return emission_points

func spawn_hit_effect(global_pos:Vector3, direction:Vector3, normal:Vector3, effect_material:String):
	var effect : PackedScene = material_hit_effects.get(effect_material)
	if effect:
		var hit_effect_instance : Node3D = effect.instantiate()
		hit_effect_instance.global_position = global_pos
		hit_effect_instance.global_transform = hit_effect_instance.global_transform.looking_at(hit_effect_instance.global_position + normal)
		LevelManager.spawn_in_level(hit_effect_instance)

func add_effect(effect:Effect):
	_current_effects.append(effect)
	effects_changed.emit()
	for modifier in effect.modifiers:
		print_debug("vehicle attributes/stats handler")
		pass
		#attributes.add_modifier(modifier)

func remove_effect(effect:Effect):
	_current_effects.erase(effect)
	effects_changed.emit()
	for modifier in effect.modifiers:
		print_debug("vehicle attributes/stats handler")
		pass
		#attributes.remove_modifier(modifier)

func get_current_effects()->Array[Effect]:
	return _current_effects
