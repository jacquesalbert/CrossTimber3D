class_name Wheel
extends Node3D

var effect_material : StringName
var surface : MaterialEffectStaticBody
var speed : float
var drive_spin : float
var traction_slip : bool

@onready var skid_tracker :Tracker= $SkidTracker
@onready var tread_tracker :Tracker= $TreadTracker
@onready var audiostream_player := $AudioStreamPlayer3D
@onready var roost_particles := $RoostParticles

@export var material_roll_sound_effects : Dictionary
@export var material_skid_sound_effects : Dictionary

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

signal surface_changed(surface:MaterialEffectStaticBody)

func _ready():
	if is_instance_valid(roost_particles):
		roost_particles.emitting = false

func _on_surface_changed(surface:MaterialEffectStaticBody):
	self.surface = surface
	if is_instance_valid(skid_tracker):
		skid_tracker.ground_area = surface
	if is_instance_valid(tread_tracker):
		tread_tracker.ground_area = surface
	if surface:
		effect_material = surface.effect_material
	else:
		effect_material = "none"
	
	if is_instance_valid(audiostream_player):
		if state == State.ROOSTING or state == State.SKIDDING:
			var roost_sound : AudioStream = material_skid_sound_effects.get(effect_material)
			audiostream_player.stream = roost_sound
			audiostream_player.playing = true
		elif state == State.ROLLING:
			var roll_sound : AudioStream = material_roll_sound_effects.get(effect_material)
			audiostream_player.stream = roll_sound
			audiostream_player.playing = true
		else:
			audiostream_player.stream = null
			audiostream_player.playing = false
	

func set_roosting():
	if is_instance_valid(skid_tracker):
		skid_tracker.enable_tracking()
	if is_instance_valid(tread_tracker):
		tread_tracker.disable_tracking()
	if is_instance_valid(roost_particles):
		roost_particles.emitting = true
	if is_instance_valid(audiostream_player):
		var roost_sound : AudioStream = material_skid_sound_effects.get(effect_material)
		audiostream_player.stream = roost_sound
		audiostream_player.playing = true

func set_skidding():
	if is_instance_valid(skid_tracker):
		skid_tracker.enable_tracking()
	if is_instance_valid(tread_tracker):
		tread_tracker.disable_tracking()
	if is_instance_valid(roost_particles):
		roost_particles.emitting = true
		roost_particles.initial_velocity_max = 0
	if is_instance_valid(audiostream_player):
		var roost_sound : AudioStream = material_skid_sound_effects.get(effect_material)
		audiostream_player.stream = roost_sound
		audiostream_player.playing = true

func set_rolling():
	if is_instance_valid(skid_tracker):
		skid_tracker.disable_tracking()
	if is_instance_valid(tread_tracker):
		tread_tracker.enable_tracking()
	if is_instance_valid(roost_particles):
		roost_particles.emitting = false
	if is_instance_valid(audiostream_player):
		var roll_sound : AudioStream = material_roll_sound_effects.get(effect_material)
		audiostream_player.stream = roll_sound
		audiostream_player.playing = true

func set_stopped():
	if is_instance_valid(skid_tracker):
		skid_tracker.disable_tracking()
	if is_instance_valid(tread_tracker):
		tread_tracker.disable_tracking()
	if is_instance_valid(roost_particles):
		roost_particles.emitting = false
	if is_instance_valid(audiostream_player):
		audiostream_player.stream = null
		audiostream_player.playing =  false

func _physics_process(delta):
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
