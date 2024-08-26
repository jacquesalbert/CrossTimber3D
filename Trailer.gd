class_name Trailer
extends Node3D

@export var min_segment_length : float = .1:
	set(value):
		min_segment_length = value
		_queue_create_trail = true
@export var texture : Texture2D:
	set(value):
		texture = value
		_queue_create_trail = true
@export var default_color : Color = Color.WHITE:
	set(value):
		default_color = value
		_queue_create_trail = true
@export var gradient : Gradient:
	set(value):
		gradient = value
		_queue_create_trail = true
@export var lifetime : float = 0.5:
	set(value):
		lifetime = value
		_queue_create_trail = true
@export var default_width : float = 2.0:
	set(value):
		default_width = value
		_queue_create_trail = true
@export var width_curve : Curve:
	set(value):
		width_curve = value
		_queue_create_trail = true
@export var normal_direction : Vector3 = Vector3.UP
@export var local_normal : bool
@export var two_sided : bool:
	set(value):
		two_sided = value
		_queue_create_trail = true


@export var trailing: bool:
	set(value):
		if value != trailing:
			trailing = value
			if trailing:
				_queue_create_trail = true

var _trail : Trail
var _queue_create_trail : bool

func create_trail():
	_trail = Trail.new()
	_trail.texture = texture
	_trail.gradient = gradient
	_trail.min_segment_length = min_segment_length
	_trail.default_color = default_color
	_trail.default_width = default_width
	_trail.width_curve = width_curve
	_trail.two_sided = two_sided
	_trail.hot_time = lifetime
	_trail.uv_t_scale = 1.0/default_width
	_trail.update_points(global_position,global_basis*normal_direction if local_normal else normal_direction)
	LevelManager.spawn_in_level(_trail)
	_queue_create_trail = false

func enable():
	trailing = true
	_queue_create_trail = true

func disable():
	trailing = false
	_trail = null

func _physics_process(delta):

	if _queue_create_trail:
		create_trail()
	if trailing and is_instance_valid(_trail):
		_trail.update_points(global_position+global_basis*normal_direction*0.05,global_basis*normal_direction if local_normal else normal_direction)
