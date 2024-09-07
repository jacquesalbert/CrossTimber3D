class_name PaintMapChunk
extends MeshInstance3D

#var mesh_size : float = 50
#var pixel_scale : float = 0.05

var _coord : Vector2i
var _material : StandardMaterial3D
var _texture : ImageTexture
var _image : Image
#var _point_queue : Array[Vector2]
#var _color_queue : Array[Color]
var _image_size : int
var _half_image_size : int
var _pixel_scale : float
var _mesh_size : float

var _thread : Thread
var _mutex : Mutex

class DrawShape:
	enum Shape{
		POINT,
		CIRCLE,
		LINE,
		THICK_LINE,
		IMAGE
	}
	
	enum Mode {
		SET,
		BLEND
	}
	
	var shape : Shape
	var mode : Mode
	var width : float
	var color : Color
	var point_a : Vector2
	var point_b : Vector2
	
var _draw_queue : Array[DrawShape]


func _init(coord:Vector2i, pixel_scale:float, image_size:int,mesh_size:float) -> void:
	self._coord = coord
	self._pixel_scale = pixel_scale
	self._image_size = image_size
	self._mesh_size = mesh_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_thread = Thread.new()
	_mutex = Mutex.new()

	#_image_size = (mesh_size / pixel_scale) + 2
	#print(_image_size)
	_half_image_size = _image_size / 2

	_image = Image.create_empty(_image_size,_image_size,false,Image.FORMAT_RGBAF)
	_image.fill(Color(0,0,0,0))
	_texture = ImageTexture.create_from_image(_image)
	
	if not is_instance_valid(_material):
		_material = StandardMaterial3D.new()
	_material.albedo_texture = _texture
	var uv_scale := float(_image_size-2)/(_image_size)
	var uv_offset := float(1.0)/_image_size
	_material.uv1_scale = Vector3.ONE * uv_scale
	_material.uv1_offset = Vector3(uv_offset,uv_offset,0)
	#_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	#_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	
	mesh = QuadMesh.new()
	mesh.orientation = PlaneMesh.FACE_Y
	mesh.size = Vector2(_mesh_size,_mesh_size)
	mesh.material = _material
	

func set_line(pos_a:Vector3, pos_b:Vector3, width:float, color:Color):
	var local_pos_a := to_local(pos_a)
	var local_pos_b := to_local(pos_b)
	var local_pos_2d_a : Vector2 = Vector2(local_pos_a.x,local_pos_a.z)
	var local_pos_2d_b : Vector2 = Vector2(local_pos_b.x,local_pos_b.z)
	var draw := DrawShape.new()
	if width == 1.0:
		draw.shape = DrawShape.Shape.LINE
	else:
		draw.shape = DrawShape.Shape.THICK_LINE
		draw.width = 5.0
	draw.mode = DrawShape.Mode.SET
	draw.color = color
	draw.point_a = local_pos_2d_a
	draw.point_b = local_pos_2d_b
	_mutex.lock()
	_draw_queue.append(draw)
	_mutex.unlock()

func set_circle(pos:Vector3, radius:float,color:Color):
	var local_pos := to_local(pos)
	var local_pos_2d : Vector2 = Vector2(local_pos.x,local_pos.z)
	var draw := DrawShape.new()
	draw.shape = DrawShape.Shape.CIRCLE
	draw.width = radius*2.0
	draw.mode = DrawShape.Mode.SET
	draw.color = color
	draw.point_a = local_pos_2d
	_mutex.lock()
	_draw_queue.append(draw)
	_mutex.unlock()

func set_point(pos:Vector3,color:Color=Color.WHITE):
	var local_pos := to_local(pos)
	var local_pos_2d : Vector2 = Vector2(local_pos.x,local_pos.z)
	var draw := DrawShape.new()
	draw.shape = DrawShape.Shape.POINT
	draw.mode = DrawShape.Mode.SET
	draw.color = color
	draw.point_a = local_pos_2d
	_mutex.lock()
	_draw_queue.append(draw)
	_mutex.unlock()

func _exit_tree() -> void:
	_thread.wait_to_finish()

func update_map():
	if not _thread.is_alive():
		_thread.start(update_image)

func update_image():
	#var _image := Image.create_empty(_image_size,_image_size,false,Image.FORMAT_RGBAF)
	_mutex.lock()
	#var points : Array[Vector2] = _point_queue.duplicate()
	#var colors : Array[Color] = _color_queue.duplicate()
	#_point_queue.clear()
	#_color_queue.clear()
	var draws : Array[DrawShape] = _draw_queue.duplicate()
	_draw_queue.clear()
	_mutex.unlock()
	while draws.size() > 0:
		#var point :Vector2= points.pop_back()
		#var color :Color= colors.pop_back()
		var draw :DrawShape= draws.pop_back()
		draw(draw)
	_texture.update(_image)
	on_image_ready.call_deferred()

func draw(draw:DrawShape):
	match draw.shape:
		DrawShape.Shape.POINT:
			draw_point(_image,draw.point_a,draw.color)
		DrawShape.Shape.LINE:
			draw_line(_image,draw.point_a,draw.point_b,draw.color)
		DrawShape.Shape.THICK_LINE:
			draw_thick_line(_image,draw.point_a,draw.point_b,draw.width, draw.color)
		DrawShape.Shape.CIRCLE:
			draw_circle(_image,draw.point_a,draw.width*0.5,draw.color)

func draw_point(image:Image, point:Vector2, color:Color):
	var image_point := point_to_image_point(point)
	var existing_color := image.get_pixelv(image_point)
	var new_color := existing_color.blend(color)
	image.set_pixelv(image_point,new_color)

func point_to_image_point(point:Vector2)->Vector2i:
	return Vector2i(floor(point.x/_pixel_scale)+_half_image_size, floor(point.y/_pixel_scale)+_half_image_size)

func point_to_image_point_f(point:Vector2)->Vector2:
	return Vector2((point.x/_pixel_scale)+_half_image_size, (point.y/_pixel_scale)+_half_image_size)

func draw_circle(image:Image, point:Vector2, radius:float, color:Color):
	var center := point_to_image_point_f(point)
	var image_radius := radius
	var max_x := center.x+image_radius
	var min_x := center.x-image_radius
	var max_y := center.y+image_radius
	var min_y := center.y-image_radius
	for x in range(min_x,max_x+1):
		for y in range(min_y,max_y+1):
			var image_point := Vector2(x+0.5,y+0.5)
			if Geometry2D.is_point_in_circle(image_point,center,image_radius):
				var existing_color := image.get_pixelv(image_point)
				var new_color := existing_color.blend(color)
				image.set_pixelv(image_point,new_color)

func draw_line(image:Image, point_a:Vector2, point_b:Vector2, color:Color):
	var image_point_a := point_to_image_point(point_a)
	var image_point_b := point_to_image_point(point_b)
	var line_points : Array[Vector2i] = get_line_points(image_point_a,image_point_b)
	for image_point in line_points:
		var existing_color := image.get_pixelv(image_point)
		var new_color := existing_color.blend(color)
		image.set_pixelv(image_point,new_color)

func draw_thick_line(image:Image, point_a:Vector2, point_b:Vector2, width:float, color:Color):
	#var image_point_a := point_to_image_point(point_a)
	#var image_point_b := point_to_image_point(point_b)
	var perp := (point_b - point_a).normalized().rotated(PI/2)* width*_pixel_scale
	var half_perp := perp * 0.5
	var corner_a := point_to_image_point_f(point_a + half_perp)
	var corner_b := point_to_image_point_f(point_a - half_perp)
	var corner_c := point_to_image_point_f(point_b + half_perp)
	var corner_d := point_to_image_point_f(point_b - half_perp)
	draw_triangle(image,corner_a, corner_b, corner_c,color)
	draw_triangle(image,corner_b, corner_c, corner_d,color)
	draw_circle(image,point_a,width*0.5,color)
	draw_circle(image,point_b,width*0.5,color)

func draw_triangle(image:Image, v1:Vector2,v2:Vector2,v3:Vector2, color:Color):
	var max_x := maxi(v1.x,maxi(v2.x,v3.x))
	var min_x := mini(v1.x,mini(v2.x,v3.x))
	var max_y := maxi(v1.y,maxi(v2.y,v3.y))
	var min_y := mini(v1.y,mini(v2.y,v3.y))
	for x in range(min_x,max_x+1):
		for y in range(min_y,max_y+1):
			var point := Vector2(x+0.5,y+0.5)
			if Geometry2D.is_point_in_polygon(point,[v1,v2,v3]):
				var existing_color := image.get_pixelv(point)
				var new_color := existing_color.blend(color)
				image.set_pixelv(point,new_color)

func get_line_points(point_a:Vector2i, point_b:Vector2i)->Array[Vector2i]:
	if abs(point_b.y - point_a.y) < abs(point_b.x - point_a.x):
		if point_a.x > point_b.x:
			return get_line_points_low(point_b, point_a)
		else:
			return get_line_points_low(point_a, point_b)
	else:
		if point_a.y > point_b.y:
			return get_line_points_high(point_b, point_a)
		else:
			return get_line_points_high(point_a, point_b)
	return []

func get_line_points_low(point_a:Vector2i, point_b:Vector2i)->Array[Vector2i]:
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

func get_line_points_high(point_a:Vector2i, point_b:Vector2i)->Array[Vector2i]:
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

func on_image_ready():
	_thread.wait_to_finish()
	
func _process(delta: float) -> void:
	if _draw_queue.size() > 0:
		update_map()
