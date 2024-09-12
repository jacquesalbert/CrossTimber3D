extends Line3D
class_name Trail

@export var min_segment_length : float = 0.1
@export var max_segment_length : float = .1
@export var hot_time : float = 0.1
@export var default_color :Color
@export var color_gradient :Gradient
@export var default_width :float = 1.0
@export var width_curve :Curve
@export var max_idle_time : float = 60.0
@export var t_from_length : bool

@export var line_transparency : BaseMaterial3D.Transparency
@export var line_shadow : GeometryInstance3D.ShadowCastingSetting
@export var line_unshaded : bool

var _point_ages : Array[float]
var _idle_time : float

signal expired

func _ready() -> void:
	super._ready()
	#_material.transparency = line_transparency
	#_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED if line_unshaded else BaseMaterial3D.SHADING_MODE_PER_PIXEL
	#_material.albedo_color = Color.WHITE * 4.0
	#_material.emission = Color.GREEN
	#_material.emission_enabled = true
	#_material.emission_energy_multiplier = 2.0
	#cast_shadow = line_shadow

func update_points(global_point:Vector3, normal:Vector3=Vector3.UP):
	var point_count := get_point_count()
	var new_point := to_local(global_point)
	var point_color := default_color*color_gradient.sample(0.0) if is_instance_valid(color_gradient) else default_color
	var point_width := default_width*width_curve.sample(0.0) if is_instance_valid(width_curve) else default_width
	if point_count > 2:
		var last_p := point_count-1
		var last_position :=  get_point_position(last_p)
		var previous_position := get_point_position(last_p-1)
		var last_segment_length := (last_position - previous_position).length()
		if last_segment_length < min_segment_length:
			set_point_position(last_p, new_point)
			set_point_age(last_p,0.0)
			set_point_width(last_p,point_width)
			set_point_color(last_p,point_color)
			var new_seg_length := (new_point - previous_position).length()
			set_point_t(last_p,get_point_t(last_p-1)+new_seg_length)
			return
		elif last_segment_length > max_segment_length:
			var segment_division := last_segment_length / max_segment_length
			var segment_division_floor : int = floor(segment_division)
			var last_age :=  get_point_age(last_p)
			var interp_seg_step : float = max_segment_length / last_segment_length
			
			for i in range(segment_division_floor):
				var interp_step := interp_seg_step*i
				var interp_point := last_position.lerp(new_point,interp_step)
				var interp_age :float= lerp(last_age,0.0,interp_step)
				var sample_offset :float= clampf(interp_age/hot_time,0.0,1.0)
				var interp_point_color := default_color*color_gradient.sample(sample_offset) if is_instance_valid(color_gradient) else default_color
				var interp_point_width := default_width*width_curve.sample(sample_offset) if is_instance_valid(width_curve) else default_width
				add_point(interp_point,normal,interp_point_width,interp_point_color,interp_age)
	add_point(new_point,normal,point_width,point_color)

func add_point(pos:Vector3,normal:Vector3,width:float,color:=default_color,age:float=0.0):
	super.add_point(pos,normal,width,color)
	_point_ages.append(age)
	_idle_time = 0.0

func remove_point(idx:int):
	super.remove_point(idx)
	_point_ages.remove_at(idx)

func get_point_age(idx:int)->float:
	return _point_ages[idx]

func set_point_age(idx:int,age:float):
	_point_ages[idx] = age
	_rebuild_queued = true

func _process(delta):
	super._process(delta)
	_idle_time += delta
	for p in range(_points.size()):
		_point_ages[p] += delta
	if _idle_time > hot_time:
		expired.emit()
		queue_free()
	update_point_colors_and_widths()

func update_point_colors_and_widths():
	var point_count := get_point_count()
	if point_count == 0:
		return
	
	while _point_ages.size() > 0 and _point_ages[0] > hot_time:
		remove_point(0)
		point_count = get_point_count()
	
	for p in range(point_count):
		var point_age := _point_ages[p]
		var sample_offset :float= clampf(point_age/hot_time,0.0,1.0)
		var point_color := default_color*color_gradient.sample(sample_offset) if is_instance_valid(color_gradient) else default_color
		var point_width := default_width*width_curve.sample(sample_offset) if is_instance_valid(width_curve) else default_width
		set_point_color(p,point_color)
		if not t_from_length:
			set_point_t(p,sample_offset)
		set_point_width(p,point_width)
