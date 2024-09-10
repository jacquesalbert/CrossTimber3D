class_name SimplePaintMap
extends PaintMap

class PointDraw:
	var mode : BlendMode
	var color : Color
	var point : Vector2i

var _chunk_mesh_dictionary : Dictionary
var _mesh_size : float
var _half_mesh_size : float
var _material : StandardMaterial3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_material = StandardMaterial3D.new()
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_mesh_size = texture_size * pixel_scale
	_half_mesh_size = _mesh_size * 0.5
	
func get_chunk_coord(point_coord : Vector2i)->Vector2i:
	return Vector2i(floor(float(point_coord.x)/texture_size), floor(float(point_coord.y)/texture_size))

func get_point_coord(pos_2d:Vector2)->Vector2i:
	return Vector2i(get_point_coord_f(pos_2d).floor())

func get_point_coord_f(pos_2d:Vector2)->Vector2:
	return Vector2(pos_2d.x/pixel_scale, pos_2d.y/pixel_scale)

func get_point_pos_2d(point:Vector3)->Vector2:
	return Vector2(point.x,point.z)

func get_point_coord_chunk(point_coord:Vector2i)->SimplePaintMapChunk:
	var point_chunk_coord := get_chunk_coord(point_coord)
	
	var chunk : SimplePaintMapChunk
	if _chunk_mesh_dictionary.has(point_chunk_coord):
		chunk = _chunk_mesh_dictionary[point_chunk_coord]
	else:
		chunk = SimplePaintMapChunk.new(point_chunk_coord,pixel_scale,texture_size,_mesh_size)
		chunk._material = _material.duplicate()
		chunk.position = Vector3(point_chunk_coord.x, 0, point_chunk_coord.y) * _mesh_size + Vector3(_half_mesh_size, 0, _half_mesh_size)
		add_child(chunk)
		_chunk_mesh_dictionary[point_chunk_coord] = chunk
	
	return chunk

func draw_line(pos_a:Vector3,pos_b:Vector3,width:float=0.0,color:Color=Color.WHITE, blend:BlendMode=BlendMode.BLEND):
	var point_coord_f_a := get_point_coord_f(get_point_pos_2d(pos_a))
	var point_coord_f_b := get_point_coord_f(get_point_pos_2d(pos_b))
	var width_points := width / pixel_scale
	var points : Array[Vector2i]
	if width > 0.0:
		points.append_array(_get_thick_line_points(point_coord_f_a, point_coord_f_b,width_points))
	else:
		points.append_array(_get_thin_line_points(point_coord_f_a,point_coord_f_b))
	_draw_points(points,color,blend)

func draw_circle(pos:Vector3,radius:float,color:Color=Color.WHITE, blend:BlendMode=BlendMode.BLEND):
	var point_coord_f := get_point_coord_f(get_point_pos_2d(pos))
	var radius_points := radius / pixel_scale
	var points := _get_circle_points(point_coord_f,radius_points)
	_draw_points(points,color,blend)

func draw_point(pos:Vector3,color:Color=Color.WHITE, blend:BlendMode=BlendMode.BLEND):
	var point_coord := get_point_coord(get_point_pos_2d(pos))
	_draw_points([point_coord],color,blend)

func draw_image(image:Image,center:Vector3,rotation:float,blend:BlendMode=BlendMode.BLEND):
	var rot : int = floor((rotation + PI/4) * 4 / TAU)
	match rot:
		0:
			pass
		1:
			image.rotate_90(CLOCKWISE)
		2:
			image.rotate_180()
		3:
			image.rotate_90(COUNTERCLOCKWISE)
	var center_2d := get_point_pos_2d(center)
	var point_colors = _get_image_point_colors(image,center_2d)
	_draw_point_colors(point_colors,blend)
	

func _get_image_point_colors(image:Image, center:Vector2)->Dictionary:
	var width := image.get_width()
	var half_width := width / 2
	var height := image.get_height()
	var half_height := height/2
	var point_colors : Dictionary
	var offset := get_point_coord(center) + Vector2i(-half_width,-half_height)
	for x in range(width):
		for y in range(height):
			var color := image.get_pixel(x,y)
			if is_zero_approx(color.a):
				continue
			point_colors[Vector2i(x,y) + offset] = color
	return point_colors

func _draw_point_colors(point_colors:Dictionary,blend:BlendMode):
	for point in point_colors:
		var chunk := get_point_coord_chunk(point)
		var draw := PointDraw.new()
		draw.point = point
		draw.mode = blend
		draw.color = point_colors[point].srgb_to_linear()
		chunk.draw(draw)

func _draw_points(points:Array[Vector2i],color:Color, blend:BlendMode):
	for point in points:
		var chunk := get_point_coord_chunk(point)
		var draw := PointDraw.new()
		draw.point = point
		draw.mode = blend
		draw.color = color.srgb_to_linear()
		chunk.draw(draw)

func _get_circle_points(center:Vector2, radius:float)->Array[Vector2i]:
	var points : Array[Vector2i]
	var max_x := center.x+radius
	var min_x := center.x-radius
	var max_y := center.y+radius
	var min_y := center.y-radius
	for x in range(min_x,max_x+1):
		for y in range(min_y,max_y+1):
			var point := Vector2(x+0.5,y+0.5)
			if Geometry2D.is_point_in_circle(point,center,radius):
				points.append(Vector2i(x,y))
	return points

func _get_thick_line_points(point_a:Vector2, point_b:Vector2, width:float)->Array[Vector2i]:
	var points_dict : Dictionary
	var perp := (point_b - point_a).normalized().rotated(PI/2)* width
	var half_perp := perp * 0.5
	var corner_a := point_a + half_perp
	var corner_b := point_a - half_perp
	var corner_c := point_b + half_perp
	var corner_d := point_b - half_perp
	for point in _get_triangle_points(corner_a,corner_b,corner_c):
		points_dict[point] = null
	for point in _get_triangle_points(corner_b,corner_c,corner_d):
		points_dict[point] = null
	for point in _get_circle_points(point_a,width*0.5):
		points_dict[point] = null
	for point in _get_circle_points(point_b,width*0.5):
		points_dict[point] = null
	var points : Array[Vector2i]
	for point in points_dict.keys():
		points.append(point)
	return points

func _get_triangle_points(v1:Vector2,v2:Vector2,v3:Vector2)->Array[Vector2i]:
	var points : Array[Vector2i]
	var max_x := maxi(v1.x,maxi(v2.x,v3.x))
	var min_x := mini(v1.x,mini(v2.x,v3.x))
	var max_y := maxi(v1.y,maxi(v2.y,v3.y))
	var min_y := mini(v1.y,mini(v2.y,v3.y))
	for x in range(min_x,max_x+1):
		for y in range(min_y,max_y+1):
			var point := Vector2(x+0.5,y+0.5)
			if Geometry2D.is_point_in_polygon(point,[v1,v2,v3]):
				points.append(Vector2i(x,y))
	return points

func _get_thin_line_points(point_a:Vector2, point_b:Vector2)->Array[Vector2i]:
	if abs(point_b.y - point_a.y) < abs(point_b.x - point_a.x):
		if point_a.x > point_b.x:
			return _get_line_points_low(point_b, point_a)
		else:
			return _get_line_points_low(point_a, point_b)
	else:
		if point_a.y > point_b.y:
			return _get_line_points_high(point_b, point_a)
		else:
			return _get_line_points_high(point_a, point_b)
	return []

func _get_line_points_low(point_a:Vector2, point_b:Vector2)->Array[Vector2i]:
	var points : Array[Vector2i]
	
	var d := point_b-point_a
	var yi := 1
	if d.y < 0:
		yi = -1
		d.y = -d.y
	var D := (2 * d.y) - d.x
	var y := point_a.y
	for x in range(point_a.x, point_b.x+1):
		points.append(Vector2i(x,y))
		if D > 0:
			y += yi
			D += (2 * (d.y - d.x))
		else:
			D += 2*d.y
	return points

func _get_line_points_high(point_a:Vector2, point_b:Vector2)->Array[Vector2i]:
	var points : Array[Vector2i]
	
	var d := point_b-point_a
	var xi := 1
	if d.x < 0:
		xi = -1
		d.x = -d.x
	var D := (2 * d.x) - d.y
	var x := point_a.x
	for y in range(point_a.y, point_b.y+1):
		points.append(Vector2i(x,y))
		if D > 0:
			x += xi
			D += (2 * (d.x - d.y))
		else:
			D += 2*d.x
	return points
