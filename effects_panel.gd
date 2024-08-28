class_name EffectsHUDPanel
extends PanelContainer

@export var effects_container : Container

var effects_owner : Node:
	set(value):
		effects_owner = value
		on_effects_owner_changed()

func on_effects_owner_changed():
	effects_owner.effects_changed.connect(on_effects_changed)

func on_effects_changed():
	for child in effects_container.get_children():
		child.queue_free()
	hide()
	for effect in effects_owner.get_current_traits():
		show()
		var effect_rect := TextureRect.new()
		effect_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		effect_rect.texture = effect.icon
		effects_container.add_child(effect_rect)
