class_name Effect
extends Node3D

@export var text : StringName
@export var icon : Texture2D
@export var stackable : bool
@export var modifiers : Array[AttributeModifier]
@export var duration : float = 0.0
@export var interval : float = 0.0

var _duration_timer : Timer
var _interval_timer : Timer

func reset_duration():
	if is_instance_valid(_duration_timer):
		_duration_timer.start(0.0)

func _enter_tree():
	if duration > 0.0:
		_duration_timer = Timer.new()
		_duration_timer.autostart = true
		_duration_timer.one_shot = true
		_duration_timer.wait_time = duration
	if interval > 0.0:
		_interval_timer = Timer.new()
		_interval_timer.autostart = true
		_interval_timer.wait_time = interval
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
