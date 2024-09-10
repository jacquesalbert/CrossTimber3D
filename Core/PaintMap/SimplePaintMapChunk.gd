class_name SimplePaintMapChunk
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

var _draw_queue : Array[SimplePaintMap.PointDraw]

func _init(coord:Vector2i, pixel_scale:float, image_size:int,mesh_size:float) -> void:
	self._coord = coord
	self._pixel_scale = pixel_scale
	self._image_size = image_size
	self._mesh_size = mesh_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_image_size = (mesh_size / pixel_scale) + 2
	#print(_image_size)
	_half_image_size = _image_size / 2

	_image = Image.create_empty(_image_size,_image_size,false,Image.FORMAT_RGBAF)
	_image.fill(Color(0,0,0,0))
	_texture = ImageTexture.create_from_image(_image)
	
	if not is_instance_valid(_material):
		_material = StandardMaterial3D.new()
	_material.albedo_texture = _texture
	
	mesh = QuadMesh.new()
	mesh.orientation = PlaneMesh.FACE_Y
	mesh.size = Vector2(_mesh_size,_mesh_size)
	mesh.material = _material

func update_image():
	while _draw_queue.size() > 0:
		var draw :SimplePaintMap.PointDraw= _draw_queue.pop_back()
		_draw(draw)
	_texture.update(_image)

func draw(draw:SimplePaintMap.PointDraw):
	_draw_queue.append(draw)

func _draw(draw:SimplePaintMap.PointDraw):
	var image_point := point_to_image_point(draw.point)
	var new_color : Color
	match draw.mode:
		PaintMap.BlendMode.BLEND:
			var existing_color := _image.get_pixelv(image_point)
			new_color = existing_color.blend(draw.color)
		PaintMap.BlendMode.ADD:
			var existing_color := _image.get_pixelv(image_point)
			new_color = existing_color+draw.color
		PaintMap.BlendMode.SUBTRACT:
			var existing_color := _image.get_pixelv(image_point)
			new_color = (existing_color-draw.color).clamp()
		PaintMap.BlendMode.MULTIPLY:
			var existing_color := _image.get_pixelv(image_point)
			new_color = existing_color*draw.color
		PaintMap.BlendMode.SET:
			new_color = draw.color
	_image.set_pixelv(image_point,new_color)

func point_to_image_point(point:Vector2i)->Vector2i:
	return point - _coord*_image_size

func _process(delta: float) -> void:
	if _draw_queue.size() > 0:
		update_image()
