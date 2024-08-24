class_name Tracker
extends SurfaceRayCast3D

@export var min_segment_length : float = .1
@export var texture : Texture2D
@export var default_color : Color = Color.WHITE
@export var gradient : Gradient
@export var lifetime : float = 0.5
@export var default_width : float = 2.0
@export var width_curve : Curve

@export var default_track_settings : TrackSettings
@export var effect_material_track_settings : Dictionary




var _trail : Trail
var _tracking_enabled : bool = true
var _trailing : bool = true
var _track_settings : TrackSettings:
	get:
		if not is_instance_valid(_track_settings):
			_track_settings = default_track_settings
		return _track_settings
		
var _queue_create_trail : bool

func create_trail():
	_trail = Trail.new()
	_trail.texture = _track_settings.texture
	_trail.gradient = gradient
	_trail.min_segment_length = min_segment_length
	_trail.default_color = _track_settings.color
	_trail.default_width = _track_settings.width
	#_trail.width_curve = width_curve
	_trail.two_sided = false
	_trail.hot_time = lifetime
	_trail.uv_t_scale = 1.0/_track_settings.width
	#_trail.update_points(global_position)
	LevelManager.spawn_in_level(_trail)
	_queue_create_trail = false

func enable_tracking():
	_tracking_enabled = true
	if _trailing and _track_settings.track:
		_queue_create_trail = true

func disable_tracking():
	_tracking_enabled = false
	_trail = null

func enable():
	_trailing = true
	if _tracking_enabled and _track_settings.track:
		_queue_create_trail = true

func disable():
	_trailing = false
	_trail = null

func _ready() -> void:
	surface_changed.connect(on_surface_changed)

func on_surface_changed(new_surface:Node3D):
	var effect_material :StringName = new_surface.get_effect_material() if is_instance_valid(new_surface) else "none"
	_track_settings = effect_material_track_settings.get(effect_material,default_track_settings)
	if _track_settings.track:
		enable()
	else:
		disable()

func _process(delta: float) -> void:
	if _queue_create_trail:
		create_trail()

func _physics_process(delta):
	super._physics_process(delta)
	if _tracking_enabled and _trailing and is_instance_valid(_trail) and is_colliding():
		_trail.update_points(get_collision_point(),get_collision_normal())
