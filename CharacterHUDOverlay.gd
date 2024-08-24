class_name CharacterHUDOverlay
extends Control

var character:Character:
	set(value):
		if is_instance_valid(character):
			character.health.changed.disconnect(on_health_changed)
			character.energy.changed.disconnect(on_energy_changed)
		character = value
		if is_instance_valid(character):
			show()
			character.health.changed.connect(on_health_changed)
			character.energy.changed.connect(on_energy_changed)
			on_health_changed(character.health.value,null)
			on_energy_changed(character.energy.value,null)
		else:
			hide()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_health_changed(value:int,changed_by:Node):
	$GridContainer/HealthBar.value = character.health.value

func on_energy_changed(value:int,changed_by:Node):
	$GridContainer/EnergyBar.value = character.energy.value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(character):
		global_position = character.get_viewport().get_camera_3d().unproject_position(character.global_position)
