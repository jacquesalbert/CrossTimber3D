class_name Wheel
extends Node3D

var speed : float
var drive_spin : float
var traction : float = 0.0
var traction_slip : bool

@onready var skid_tracker :Tracker= $SkidTracker
@onready var tread_tracker :Tracker= $TreadTracker
@onready var audiostream_player := $AudioStreamPlayer3D
@onready var roost_particles := $RoostParticles
@onready var ray_cast :RayCast3D= $RayCast3D

@export var material_roll_sound_effects : Dictionary
@export var material_skid_sound_effects : Dictionary
@export var material_deposit_distances : Dictionary

enum State {
	STOPPED,
	ROLLING,
	SKIDDING,
	ROOSTING
}
var state : State:
	set(value):
		if state != value:
			state = value
			match state:
				State.STOPPED:
					set_stopped()
				State.ROLLING:
					set_rolling()
				State.SKIDDING:
					set_skidding()
				State.ROOSTING:
					set_roosting()

signal surface_changed(surface:NodeMaterial)

var _current_surface : NodeMaterial:
	set(value):
		if _current_surface != value:
			_current_surface = value
			_on_surface_changed(_current_surface)
			surface_changed.emit(_current_surface)

var _current_effect_material : NodeMaterial
var _active_effect_material : NodeMaterial
var _deposit_remaining : float = 0.0


func _ready():
	if is_instance_valid(roost_particles):
		roost_particles.emitting = false

func _on_surface_changed(surface:NodeMaterial):
	_current_effect_material = surface
	if _current_effect_material != _active_effect_material:
		_deposit_remaining = material_deposit_distances.get(_active_effect_material,0.0)
	traction = surface.traction if is_instance_valid(surface) else 0.0

func change_active_material(new_material:NodeMaterial):
	_active_effect_material = new_material
	
	if is_instance_valid(skid_tracker):
		skid_tracker.change_effect_material(_active_effect_material)
	if is_instance_valid(tread_tracker):
		tread_tracker.change_effect_material(_active_effect_material)
	if is_instance_valid(audiostream_player):
		if state == State.ROOSTING or state == State.SKIDDING:
			var roost_sound : AudioStream = material_skid_sound_effects.get(_active_effect_material)
			audiostream_player.stream = roost_sound
			audiostream_player.playing = true
		elif state == State.ROLLING:
			var roll_sound : AudioStream = material_roll_sound_effects.get(_active_effect_material)
			audiostream_player.stream = roll_sound
			audiostream_player.playing = true
		else:
			audiostream_player.stream = null
			audiostream_player.playing = false

func set_roosting():
	if is_instance_valid(skid_tracker):
		skid_tracker.enable()
	if is_instance_valid(tread_tracker):
		tread_tracker.disable()
	if is_instance_valid(roost_particles):
		roost_particles.emitting = true
	if is_instance_valid(audiostream_player):
		var roost_sound : AudioStream = material_skid_sound_effects.get(_active_effect_material)
		audiostream_player.stream = roost_sound
		audiostream_player.playing = true

func set_skidding():
	if is_instance_valid(skid_tracker):
		skid_tracker.enable()
	if is_instance_valid(tread_tracker):
		tread_tracker.disable()
	if is_instance_valid(roost_particles):
		roost_particles.emitting = true
		roost_particles.initial_velocity_max = 5
	if is_instance_valid(audiostream_player):
		var roost_sound : AudioStream = material_skid_sound_effects.get(_active_effect_material)
		audiostream_player.stream = roost_sound
		audiostream_player.playing = true

func set_rolling():
	if is_instance_valid(skid_tracker):
		skid_tracker.disable()
	if is_instance_valid(tread_tracker):
		tread_tracker.enable()
	if is_instance_valid(roost_particles):
		roost_particles.emitting = false
	if is_instance_valid(audiostream_player):
		var roll_sound : AudioStream = material_roll_sound_effects.get(_active_effect_material)
		audiostream_player.stream = roll_sound
		audiostream_player.playing = true

func set_stopped():
	if is_instance_valid(skid_tracker):
		skid_tracker.disable()
	if is_instance_valid(tread_tracker):
		tread_tracker.disable()
	if is_instance_valid(roost_particles):
		roost_particles.emitting = false
	if is_instance_valid(audiostream_player):
		audiostream_player.stream = null
		audiostream_player.playing =  false

func _physics_process(delta):
	if _active_effect_material != _current_effect_material:
		_deposit_remaining -= speed * delta
		if _deposit_remaining <= 0.0:
			_deposit_remaining = 0
			change_active_material(_current_effect_material)
	
	var cast_material : NodeMaterial
	if ray_cast.is_colliding():
		tread_tracker.global_position = ray_cast.get_collision_point()
		tread_tracker.normal_direction = ray_cast.get_collision_normal()
		skid_tracker.global_position = ray_cast.get_collision_point()
		skid_tracker.normal_direction = ray_cast.get_collision_normal()
		cast_material = NodeMaterial.get_collision_shape_material(ray_cast.get_collider(),ray_cast.get_collider_shape())
	_current_surface = cast_material
	
	if is_zero_approx(speed):
		state = State.STOPPED
	elif abs(drive_spin) > 0.0:
		state = State.ROOSTING
		if is_instance_valid(roost_particles):
			roost_particles.direction.z = -sign(drive_spin)
			roost_particles.initial_velocity_max = abs(drive_spin) * 2.0
		if is_instance_valid(audiostream_player):
			audiostream_player.volume_db = lerp(-9.0,0.0,drive_spin / 50.)
	elif traction_slip:
		state = State.SKIDDING
		if is_instance_valid(audiostream_player):
			audiostream_player.volume_db = lerp(-9.0,0.0,speed / 500.)
	else:
		state = State.ROLLING
		if is_instance_valid(audiostream_player):
			audiostream_player.volume_db = lerp(-9.0,0.0,speed / 500.)
