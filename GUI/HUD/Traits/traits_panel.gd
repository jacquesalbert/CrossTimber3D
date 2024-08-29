class_name TraitsHUDPanel
extends PanelContainer

@export var traits_container : Container

var traits_owner : Node:
	set(value):
		traits_owner = value
		on_traits_owner_changed()

func on_traits_owner_changed():
	traits_owner.traits_changed.connect(on_traits_changed)

func on_traits_changed():
	for child in traits_container.get_children():
		child.queue_free()
	visible = false
	for character_trait in traits_owner.get_current_traits():
		visible = true
		var trait_rect := TextureRect.new()
		trait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		trait_rect.texture = character_trait.icon
		traits_container.add_child(trait_rect)
