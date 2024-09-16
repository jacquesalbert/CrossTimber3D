class_name RigidBodyVehicle
extends RigidBody3D

#const COLLISION_CONSEVATION : float = 0.5
const CHARACTER_COLLISION_DAMAGE_ENERGY_RATIO : float = 2.0
const CONTACT_VELOCITY_EFFECT_THRESHOLD : float = 10.0

enum State {
	STOPPED,
	RUNNING,
	DESTROYED
}


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
#@export var mass : float = 1500
#@export var ride_height : float = 0.1
@export var rolling_resistance : float = 0.1
@export var fuel_consumpution_rate : float = 1.0
@export var traction_control_modifier : float = 0.8
@export var fuel : Stat
@export var health : Stat
@export var num_gears :int= 5
@export var gear_scale :float= 2.0
@export var taillights : Array[SpotLight3D]
@export var headlights : Array[SpotLight3D]
@export var brake_light_intensity : float = 5.0
@export var taillight_intensity : float = 2.0
@export var vehicle_graphics : VehicleGraphics


#@export var emission_texture : Texture
#@export var emission_points : int = 100.0

@export var material_hit_effects : Dictionary

@onready var front_left_wheel : Wheel= $FLWheel
@onready var front_right_wheel :Wheel= $FRWheel
@onready var rear_left_wheel :Wheel= $RLWheel
@onready var rear_right_wheel :Wheel= $RRWheel

@onready var engine_stream_player := $AudioStreamPlayer3D
@export var start_stream : AudioStream
@export var idle_stream : AudioStream
@export var drive_stream : AudioStream
@export var stop_stream : AudioStream

@onready var door_stream_player := $AudioStreamPlayer3D2


@export var driver_character : Character:
	set(value):
		if driver_character != value:
			if is_instance_valid(door_stream_player):
				door_stream_player.play()
			driver_character = value
			if not disabled:
				if is_instance_valid(driver_character):
					set_running()
				else:
					if linear_velocity.length() < 1.0:
						set_stopped()

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
var _steer_angle : float
var _state : State

signal effects_changed
signal destroyed
signal restored

func _ready():
	front_axle_distance = (front_left_wheel.position.z + front_right_wheel.position.z) * 0.5
	rear_axle_distance = (rear_left_wheel.position.z + rear_right_wheel.position.z) * 0.5
	wheelbase = front_axle_distance - rear_axle_distance

	health.changed.connect(_on_health_changed)
	health.expended.connect(_on_health_expended)
	
	set_stopped()

func _on_health_changed(amount:int,responsible_node:Node):
	vehicle_graphics.damage = 1.0-float(health.value)/health.max_value
	
func _on_health_expended(responsible_node:Node):
	set_destroyed()
	destroyed.emit()

func _on_health_restored(responsible_node:Node):
	set_stopped()
	restored.emit()

var throttle : float:
	set(value):
		throttle = clamp(value, -1.0,1.0)

var brake : float:
	set(value):
		brake = clamp(value,0.0,1.0)
		update_lights()
				

var steer : float:
	set(value):
		steer = clamp(value,-1.0,1.0)

var traction_control : bool = true

func get_input_debug():
	steer = Input.get_axis("ui_left","ui_right")
	throttle = Input.get_axis("ui_down","ui_up")
	brake = 1.0 if Input.is_action_pressed("ui_select") else 0.0

func get_input(delta:float):
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
	match _state:
		State.STOPPED:
			_stopped_process(delta)
		State.RUNNING:
			_running_process(delta)
		State.DESTROYED:
			_destroyed_process(delta)

func _stopped_process(delta:float):
	pass

func _running_process(delta:float):
	get_input(delta)
	update_lights()
	update_sounds()

func _destroyed_process(delta:float):
	pass

func update_lights():
	if _state == State.DESTROYED or _state == State.STOPPED:
		for headlight in headlights:
			headlight.visible = false
		for taillight in taillights:
			taillight.visible = false
		return
	
	for headlight in headlights:
		if LevelManager.current_level.is_daytime():
			headlight.visible = false
		else:
			headlight.visible = true
	for taillight in taillights:
		if brake > 0.1:
			taillight.visible = true
			taillight.light_energy = brake_light_intensity
		else:
			if LevelManager.current_level.is_daytime():
				taillight.visible = false
			else:
				taillight.visible = true
				taillight.light_energy = taillight_intensity

func update_sounds():
	if is_instance_valid(driver_character) and is_instance_valid(engine_stream_player):

		var speed :float= abs(linear_velocity.dot(global_basis.z))
		var relative_speed := gear_scale * speed / top_speed
		var gear_width := gear_scale / num_gears
		var this_gear_speed :float = floor(relative_speed / gear_width)*gear_width
		var engine_speed := relative_speed - this_gear_speed
		engine_stream_player.pitch_scale = min(2.0,1.0 + engine_speed) if brake < 0.5 else 1.0

func run_fuel(delta:float):
	if _state == State.RUNNING:
		_fuel_debt += fuel_consumpution_rate * abs(throttle) * delta
		if _fuel_debt > 1.0 and fuel.value > 0:
			var fuel_consumption_amount : int = floor(_fuel_debt)
			fuel.modify(-fuel_consumption_amount,driver_character)
			_fuel_debt -= fuel_consumption_amount
	fueled = fuel.value > 0

func get_speedo()->float:
	return abs(linear_velocity.dot(global_basis.z))

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var forward := global_basis.z
	var right := -global_basis.x
	run_fuel(state.step)

	var longitudinal_speed := linear_velocity.dot(forward)
	#apply_central_force(-forward * longitudinal_speed * rolling_resistance)
	linear_velocity -= forward * longitudinal_speed * rolling_resistance * state.step
	
	_steer_angle= move_toward(_steer_angle,-steer * max_steer_angle, handling_speed * state.step)
	front_left_wheel.rotation.y = _steer_angle
	front_right_wheel.rotation.y = _steer_angle
	var rotation_speed :float = (longitudinal_speed / wheelbase) * tan(_steer_angle)
	
	var fl_traction :float= front_left_wheel.traction if front_left_wheel.is_colliding() else 0.0
	var fr_traction :float= front_right_wheel.traction if front_right_wheel.is_colliding() else 0.0
	var rl_traction :float= rear_left_wheel.traction if rear_left_wheel.is_colliding() else 0.0
	var rr_traction :float= rear_right_wheel.traction if rear_right_wheel.is_colliding() else 0.0
	var front_traction :float= max(fl_traction,fr_traction)
	var rear_traction :float= max(rl_traction,rr_traction)
	var all_traction : float = max(front_traction,rear_traction)
	
	var fl_normal :Vector3= front_left_wheel.get_collision_normal()
	var fr_normal :Vector3= front_right_wheel.get_collision_normal()
	var rl_normal :Vector3= rear_left_wheel.get_collision_normal()
	var rr_normal :Vector3= rear_right_wheel.get_collision_normal()
	var all_normal := (fl_normal+fr_normal+rl_normal+rr_normal) * 0.25
	
	var surface_right := forward.cross(all_normal)
	var surface_forward := right.cross(all_normal)
	
	var forward_vel := linear_velocity.dot(surface_forward)
	
	var right_vel := linear_velocity.dot(surface_right)
	
	var lateral_traction_accel := -right_vel / state.step

	
	## add rotation from steering
	var current_rotation_speed := angular_velocity.dot(global_basis.y)
	var rotation_speed_diff := rotation_speed - current_rotation_speed
	angular_velocity += rotation_speed_diff * global_basis.y
	var steering_lateral_speed := -rear_axle_distance * angular_speed
	## add lateral movement from steering
	global_position += -right * steering_lateral_speed * state.step
	## apply angular speed
	global_rotation.y += angular_speed * state.step
	#
	## cancel lateral movement up to lateral tracking max
	#var lateral_movement := linear_velocity.dot(right)
	#var lateral_accel := lateral_movement / delta
	

	var spin : float = 0.0
	# apply drive movement up to traction maximum
	#var speed_modifier :float = max(0,(top_speed - abs(longitudinal_speed)) / top_speed)
	var engine_power := power_curve.sample(abs(longitudinal_speed)/top_speed) * max_engine_power if _state == State.RUNNING else 0.0
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
	
	#velocity += drive_accel * delta * forward
	apply_central_force(drive_accel * forward * mass)
	
	var front_skid := false
	var rear_skid := false
	#apply braking traction
	var braking_acceleration :float
	match _state:
		State.STOPPED:
			braking_acceleration = brake * -forward_vel / state.step
		State.RUNNING:
			braking_acceleration = brake * -forward_vel / state.step
		State.DESTROYED:
			braking_acceleration = -forward_vel / state.step

	#velocity -= lateral_accel * delta * global_transform.y
	var total_traction_acceleration := braking_acceleration * surface_forward + lateral_traction_accel*surface_right

	var effective_max_traction_accel := all_traction * max_traction_accel
	var modified_max_traction_acceleration := effective_max_traction_accel if traction_control else effective_max_traction_accel * traction_control_modifier
	if total_traction_acceleration.length() > effective_max_traction_accel:
		front_skid = true
		rear_skid = true
		total_traction_acceleration = modified_max_traction_acceleration * total_traction_acceleration.normalized()
	apply_central_force(total_traction_acceleration * mass)

	front_left_wheel.traction_slip = front_skid
	front_right_wheel.traction_slip = front_skid
	rear_left_wheel.traction_slip = rear_skid
	rear_right_wheel.traction_slip = rear_skid
	
	front_left_wheel.speed = abs(longitudinal_speed)
	front_right_wheel.speed = abs(longitudinal_speed)
	rear_left_wheel.speed = abs(longitudinal_speed)
	rear_right_wheel.speed = abs(longitudinal_speed)
	
	for c in range(state.get_contact_count()):
		var impulse := state.get_contact_impulse(c)
		var velocity := state.get_contact_local_velocity_at_position(c)
		var other_velocity := state.get_contact_collider_velocity_at_position(c)
		var normal := state.get_contact_local_normal(c)
		var contact_velocity := velocity.dot(normal) - other_velocity.dot(normal)
		if abs(contact_velocity) >= CONTACT_VELOCITY_EFFECT_THRESHOLD and velocity.length() > 10.0:
			var body := state.get_contact_collider_object(c)
			var shape := state.get_contact_collider_shape(c)
			var contact_position := state.get_contact_local_position(c)
			var effect_material := NodeMaterial.get_collision_shape_material(body,shape)
			var effect : PackedScene = material_hit_effects.get(effect_material)
			LevelManager.spawn_hit_effect_in_level(contact_position,velocity.normalized(),normal,effect)
			if body is Character and velocity.length() > 10.0:
				var mass_ratio :float = mass / (body.mass + mass)
				var damage :int = -floor(abs(contact_velocity)*mass_ratio*CHARACTER_COLLISION_DAMAGE_ENERGY_RATIO)
				body.hitbox.hit(damage,driver_character)

func set_stopped():
	_state = State.STOPPED
	engine_stream_player.playing = false
	vehicle_graphics.destroyed = false
	disabled = false
	update_lights()
	update_sounds()

func set_destroyed():
	_state = State.DESTROYED
	engine_stream_player.playing = false
	vehicle_graphics.destroyed = true
	disabled = true
	update_lights()
	update_sounds()

func set_running():
	_state = State.RUNNING
	engine_stream_player.playing = true
	vehicle_graphics.destroyed = false
	disabled = false
	update_lights()
	update_sounds()

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
