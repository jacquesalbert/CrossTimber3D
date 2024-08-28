class_name CharacterHUDPanel
extends PanelContainer

@export var health_stat_panel : StatPanel
@export var energy_stat_panel : StatPanel
@export var effects_panel : EffectsHUDPanel
@export var traits_panel : TraitsHUDPanel

var character : Character:
	set(value):
		character = value
		on_character_changed()

func on_character_changed():
	effects_panel.effects_owner = character
	traits_panel.traits_owner = character
	health_stat_panel.stat = character.health
	energy_stat_panel.stat = character.energy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
