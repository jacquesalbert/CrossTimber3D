class_name Trait
extends Node

@export var text : StringName
@export var icon : Texture2D
@export var stackable : bool
@export var modifiers : Array[AttributeModifier]

func _enter_tree():
	if not stackable:
		var stack_overlap_effect : Effect
		for sibling in get_parent().get_children():
			if sibling == self:
				continue
			if sibling is Effect and not sibling.stackable and sibling.text == text:
				stack_overlap_effect = sibling
		if is_instance_valid(stack_overlap_effect):
			stack_overlap_effect.reset_duration()
			queue_free()
