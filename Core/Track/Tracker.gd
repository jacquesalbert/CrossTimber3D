class_name Tracker
extends Node3D

@export var min_segment_length : float = .1
@export var texture : Texture2D
@export var lifetime : float = 10.0
@export var normal_direction : Vector3 = Vector3.UP
@export var local_normal : bool
@export var two_sided : bool
@export var bias : float = 0.01
var color : Color = Color.BLACK
var strength : float = 0.1


@export var default_track_settings : TrackSettings
@export var effect_material_track_settings : Dictionary

@export var tracking: bool:
	set(value):
		if value != tracking:
			tracking = value
			if tracking:
				enable()
			else:
				disable()

var _current_effect_material : NodeMaterial
var _track_settings:TrackSettings
var _track : Track
var _prev_position : Vector3

func _ready() -> void:
	_prev_position = global_position
	_track_settings = default_track_settings
	change_effect_material(null)

func create_track():
	_track = Track.new()
	_track.texture = texture
	_track.min_segment_length = min_segment_length
	_track.two_sided = two_sided
	_track.lifetime = lifetime
	_track.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	#_track.update_points(global_position+global_basis*normal_direction*bias,global_basis*normal_direction if local_normal else normal_direction)
	LevelManager.spawn_in_level(_track)
	#_queue_create_track = false

func change_effect_material(new_material:NodeMaterial):
	_current_effect_material = new_material
	_track_settings = effect_material_track_settings.get(_current_effect_material,default_track_settings)

func enable():
	tracking = true
	if not is_instance_valid(_track_settings):
		_track_settings = default_track_settings
	if _track_settings.track:
		add_current_point()

func disable():
	_track = null
	tracking = false

func add_current_point():
	if not is_instance_valid(_track) or not _track.is_inside_tree():
		create_track()
	#_track.add_point(global_position+global_basis*normal_direction*bias,global_basis*normal_direction if local_normal else normal_direction,_track_settings.width,_track_settings.color)
	LevelManager.current_level.paint_map.draw_line(global_position, _prev_position,_track_settings.width, _track_settings.color,PaintMap.BlendMode.BLEND)

func _physics_process(delta):
	if tracking and _track_settings.track:
		add_current_point()
	_prev_position = global_position
