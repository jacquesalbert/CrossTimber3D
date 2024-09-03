class_name Trailer
extends Node3D

@export var min_segment_length : float = .1
@export var texture : Texture2D
@export var lifetime : float = 10.0
@export var normal_direction : Vector3 = Vector3.UP
@export var local_normal : bool
@export var two_sided : bool
@export var width : float = 0.1
@export var color : Color = Color.WHITE
@export var gradient : Gradient
@export var width_curve : Curve
@export var bias : float = 0.01
@export var cast_shadow : GeometryInstance3D.ShadowCastingSetting = GeometryInstance3D.ShadowCastingSetting.SHADOW_CASTING_SETTING_OFF
@export var transparency : BaseMaterial3D.Transparency = BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA
@export var unshaded : bool = false

@export var trailing: bool:
	set(value):
		if value != trailing:
			trailing = value
			if trailing:
				enable()
			else:
				disable()

var _trail : Trail

func create_trail():
	_trail = Trail.new()
	_trail.texture = texture
	_trail.min_segment_length = min_segment_length
	_trail.two_sided = two_sided
	_trail.hot_time = lifetime
	_trail.gradient = gradient
	_trail.width_curve = width_curve
	_trail.default_width = width
	_trail.default_color = color
	_trail.line_shadow = cast_shadow
	_trail.line_transparency = transparency
	_trail.line_unshaded = unshaded
	LevelManager.spawn_in_level(_trail)
	
func enable():
	trailing = true
	add_current_point()

func disable():
	if trailing:
		add_current_point()
	_trail = null
	trailing = false

func add_current_point():
	if not is_instance_valid(_trail):
		create_trail()
	_trail.update_points(global_position+global_basis*normal_direction*bias,global_basis*normal_direction if local_normal else normal_direction)

func _physics_process(delta):
	if trailing:
		add_current_point()
