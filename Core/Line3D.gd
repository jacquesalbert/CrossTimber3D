class_name Line3D
extends MeshInstance3D

#@export var texture : Texture2D
@export var two_sided : bool
@export var keep_aspect : bool
#@export var emission_texture : Texture2D


var _points : Array[Vector3]
var _normals : Array[Vector3]
var _widths : Array[float]
var _colors : Array[Color]
var _uv_ts : Array[float]

var _rebuild_queued : bool
@export var material : Material

func _ready() -> void:
	_rebuild_queued = true
	#_material = StandardMaterial3D.new()
	#_material.texture_repeat = true
	#_material.albedo_texture = texture
	#_material.vertex_color_is_srgb = true
	#_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	#_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	#_material.emission_enabled = is_instance_valid(emission_texture)
	#_material.emission = Color.RED
	#_material.emission_texture = emission_texture
	#_material.emission_energy_multiplier = 5.0
	#_material.vertex_color_use_as_albedo = true

func clear_points():
	_points.clear()
	_normals.clear()
	_widths.clear()
	_colors.clear()
	_uv_ts.clear()
	_rebuild_queued = true

func add_point(pos:Vector3,normal:Vector3,width:float,color:=Color.WHITE):
	var prev_t := _uv_ts[_points.size()-1] if _points.size() > 0 else 0.0
	_points.append(pos)
	_normals.append(normal)
	_widths.append(width)
	_colors.append(color)
	var seg_length :float= (_points[_points.size()-1] - _points[_points.size()-2]).length() if _points.size() > 1 else 0.0
	var t := prev_t + seg_length
	_uv_ts.append(t)
	_rebuild_queued = true

func remove_point(idx:int):
	_points.remove_at(idx)
	_normals.remove_at(idx)
	_widths.remove_at(idx)
	_colors.remove_at(idx)
	_uv_ts.remove_at(idx)
	_rebuild_queued = true

func rebuild_mesh():
	if not is_instance_valid(mesh):
		mesh = ImmediateMesh.new()
	mesh.clear_surfaces()
	build_mesh_side()
	if two_sided:
		build_mesh_side(true)
	_rebuild_queued = false

func build_mesh_side(reverse:bool=false):
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	var side_modifier := -1 if reverse else 1
	var texture_width_ratio :float = float(material.albedo_texture.get_height()) / material.albedo_texture.get_width() if is_instance_valid(material.albedo_texture) else 1.0
	for p in range(_points.size()):
		#progress += (_points[p] - _points[p-1]).length() if p > 0 else 0.0
		var point_center := _points[p]
		var point_normal := _normals[p]
		var point_width := _widths[p] if not is_zero_approx(_widths[p]) else 0.001
		var half_width := point_width * 0.5
		var point_color := _colors[p]
		var point_t := _uv_ts[p]

		var tangent := (_points[p+1] - _points[p]).normalized() if p < _points.size()-1 else (_points[p] - _points[p-1]).normalized()
		var cross := tangent.cross(point_normal)
		var point_a := point_center + side_modifier * (cross * half_width)
		var point_b := point_center - side_modifier * (cross * half_width)
		
		var texture_width_scale : float = texture_width_ratio/point_width if keep_aspect else 1.0
		
		mesh.surface_set_normal(point_normal)
		mesh.surface_set_uv(Vector2(point_t*texture_width_scale, 1))
		mesh.surface_set_color(point_color)
		mesh.surface_add_vertex(point_a)
		
		mesh.surface_set_normal(point_normal)
		mesh.surface_set_uv(Vector2(point_t*texture_width_scale, 0))
		mesh.surface_set_color(point_color)
		mesh.surface_add_vertex(point_b)

	# End drawing.
	mesh.surface_end()
	mesh.surface_set_material(reverse,material)

func get_point_count()->int:
	return _points.size()

func get_point_position(idx:int)->Vector3:
	return _points[idx]

func get_point_normal(idx:int)->Vector3:
	return _normals[idx]

func get_point_width(idx:int)->float:
	return _widths[idx]

func get_point_color(idx:int)->Color:
	return _colors[idx]

func get_point_t(idx:int)->float:
	return _uv_ts[idx]

func set_point_position(idx:int,pos:Vector3):
	_points[idx] = pos
	_rebuild_queued = true

func set_point_normal(idx:int, normal:Vector3):
	_normals[idx] = normal
	_rebuild_queued = true

func set_point_width(idx:int, width:float):
	_widths[idx] = width
	_rebuild_queued = true

func set_point_color(idx:int, color:Color):
	_colors[idx] = color
	_rebuild_queued = true

func set_point_t(idx:int, t:float):
	_uv_ts[idx] = t
	_rebuild_queued = true

func _process(delta: float) -> void:
	if _rebuild_queued:
		rebuild_mesh()
