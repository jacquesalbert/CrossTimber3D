class_name Trailer
extends Node3D

@export var min_segment_length : float = .1
@export var texture : Texture2D
@export var default_color : Color = Color.WHITE
@export var gradient : Gradient
@export var lifetime : float = 0.5
@export var default_width : float = 2.0
@export var width_curve : Curve
@export var normal_direction : Vector3 = Vector3.UP
@export var local_normal : bool
@export var two_sided : bool


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
	_trail.update_points(global_position)
	LevelManager.spawn_in_level(_trail)
	_queue_create_trail = false

func enable():
	trailing = true
	_queue_create_trail = true

func disable():
	trailing = false
	_trail = null

func _process(delta: float) -> void:
	if _queue_create_trail:
		create_trail()

func _physics_process(delta):
	if trailing and is_instance_valid(_trail):
		_trail.update_points(global_position,global_basis*normal_direction if local_normal else normal_direction)
