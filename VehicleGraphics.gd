class_name VehicleGraphics
extends Node3D

@export var full_damage_smoke_color : Color = Color(.13,.13,.13)
@export var fire_particles : GPUParticles3D
@export var fire_light : OmniLight3D
@export var fire_light_gradient : Gradient
@export var smoke_particles : GPUParticles3D
@export var noise : Noise
@export_range(0.0,1000.0) var noise_time_scale : float = 200
@export_range(0.0,10.0) var fire_light_max_energy : float = 5

var damage : float:
	set(value):
		damage = value
		_on_set_damage(damage)

var destroyed : bool:
	set(value):
		destroyed = value
		if destroyed:
			_on_destroyed()
		else:
			_on_restored()



var _time : float

func _on_set_damage(damage:float):
	smoke_particles.amount_ratio = damage
	(smoke_particles.draw_pass_1.surface_get_material(0) as StandardMaterial3D).albedo_color = Color.WHITE.lerp(full_damage_smoke_color,damage)

func _on_destroyed():
	fire_light.visible = true
	fire_particles.emitting = true

func _on_restored():
	fire_light.visible = false
	fire_particles.emitting = false

func destroyed_process(delta: float):
	_time += delta
	var scaled_time := _time * noise_time_scale
	var noise_value := ((noise.get_noise_1d(scaled_time) + 1.0) * 0.5)
	fire_light.light_energy = noise_value * fire_light_max_energy
	fire_light.light_color = fire_light_gradient.sample(noise_value)

func _ready() -> void:
	damage = 0
	destroyed = false

func _process(delta: float) -> void:
	if destroyed:
		destroyed_process(delta)
