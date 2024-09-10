class_name Wheel
extends Node3D

var speed : float
var drive_spin : float
var traction : float = 0.0
var traction_slip : bool

@onready var skid_tracker :TrackPrinter= $SkidTracker
@onready var tread_tracker :TrackPrinter= $TreadTracker
@onready var skidstream_player := $SkidStreamPlayer3D
@onready var rollstream_player := $RollStreamPlayer3D
@onready var roost_particles := $RoostParticles

@export var material_roll_sound_effects : Dictionary
@export var material_skid_sound_effects : Dictionary
#@export var material_deposit_distances : Dictionary

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

#var _current_effect_material : NodeMaterial
#var _active_effect_material : NodeMaterial
#var _deposit_remaining : float = 0.0


func _ready():
	if is_instance_valid(roost_particles):
		roost_particles.emitting = false

func _on_surface_changed(surface:NodeMaterial):
	#_current_effect_material = surface
	traction = surface.traction if is_instance_valid(surface) else 1.0
	skid_tracker.change_effect_material(surface)
	tread_tracker.change_effect_material(surface)
	var roost_sound : AudioStream = material_skid_sound_effects.get(surface)
	skidstream_player.stream = roost_sound
	var roll_sound : AudioStream = material_roll_sound_effects.get(surface)
	rollstream_player.stream = roll_sound

#func change_active_material(new_material:NodeMaterial):
	#_active_effect_material = new_material
	#
	#if is_instance_valid(skid_tracker):
		#skid_tracker.change_effect_material(_active_effect_material)
	#if is_instance_valid(tread_tracker):
		#tread_tracker.change_effect_material(_active_effect_material)
	#if is_instance_valid(audiostream_player):
		#if state == State.ROOSTING or state == State.SKIDDING:
			#var roost_sound : AudioStream = material_skid_sound_effects.get(_active_effect_material)
			#audiostream_player.stream = roost_sound
			#audiostream_player.playing = true
		#elif state == State.ROLLING:
			#var roll_sound : AudioStream = material_roll_sound_effects.get(_active_effect_material)
			#audiostream_player.stream = roll_sound
			#audiostream_player.playing = true
		#else:
			#audiostream_player.stream = null
			#audiostream_player.playing = false

func set_roosting():
	if is_instance_valid(skid_tracker):
		skid_tracker.enable()
	if is_instance_valid(tread_tracker):
		tread_tracker.disable()
	if is_instance_valid(roost_particles):
		roost_particles.emitting = true
	skidstream_player.playing = true
	rollstream_player.playing = false

func set_skidding():
	if is_instance_valid(skid_tracker):
		skid_tracker.enable()
	if is_instance_valid(tread_tracker):
		tread_tracker.disable()
	if is_instance_valid(roost_particles):
		roost_particles.emitting = true
		roost_particles.initial_velocity_max = 5
	skidstream_player.playing = true
	rollstream_player.playing = false

func set_rolling():
	if is_instance_valid(skid_tracker):
		skid_tracker.disable()
	if is_instance_valid(tread_tracker):
		tread_tracker.enable()
	if is_instance_valid(roost_particles):
		roost_particles.emitting = false
	skidstream_player.playing = false
	rollstream_player.playing = true

func set_stopped():
	if is_instance_valid(skid_tracker):
		skid_tracker.disable()
	if is_instance_valid(tread_tracker):
		tread_tracker.disable()
	if is_instance_valid(roost_particles):
		roost_particles.emitting = false
	skidstream_player.playing = false
	rollstream_player.playing = false

func _physics_process(delta):
	
	if is_zero_approx(speed):
		state = State.STOPPED
	elif abs(drive_spin) > 0.0:
		state = State.ROOSTING
		if is_instance_valid(roost_particles):
			roost_particles.direction.z = -sign(drive_spin)
			roost_particles.initial_velocity_max = abs(drive_spin) * 2.0
		skidstream_player.volume_db = lerp(-9.0,0.0,drive_spin / 50.)
	elif traction_slip:
		state = State.SKIDDING
		skidstream_player.volume_db = lerp(-18.0,0.0,speed / 50.)
	else:
		state = State.ROLLING
		rollstream_player.volume_db = lerp(-18.0,0.0,speed / 50.)
