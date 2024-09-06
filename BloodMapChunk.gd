class_name BloodMapChunk
extends MeshInstance3D

#var mesh_size : float = 50
#var pixel_scale : float = 0.05

var _coord : Vector2i
var _material : StandardMaterial3D
var _texture : ImageTexture
var _image : Image
var _point_queue : Array[Vector2]
var _color_queue : Array[Color]
var _image_size : int
var _half_image_size : int
var _pixel_scale : float
var _mesh_size : float

var _thread : Thread
var _mutex : Mutex

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
	
	
func set_point(pos:Vector3,color:Color=Color.WHITE):
	var local_pos := to_local(pos)
	var local_pos_2d : Vector2 = Vector2(local_pos.x,local_pos.z)
	if not _point_queue.has(local_pos_2d):
		_mutex.lock()
		_point_queue.append(local_pos_2d)
		_color_queue.append(color)
		_mutex.unlock()

func _exit_tree() -> void:
	_thread.wait_to_finish()

func update_map():
	if not _thread.is_alive():
		_thread.start(update_image)

func update_image():
	#var _image := Image.create_empty(_image_size,_image_size,false,Image.FORMAT_RGBAF)
	_mutex.lock()
	var points : Array[Vector2] = _point_queue.duplicate()
	var colors : Array[Color] = _color_queue.duplicate()
	_point_queue.clear()
	_color_queue.clear()
	_mutex.unlock()
	while points.size() > 0:
		var point :Vector2= points.pop_back()
		var color :Color= colors.pop_back()
		var image_point := Vector2i(floor(point.x/_pixel_scale)+_half_image_size, floor(point.y/_pixel_scale)+_half_image_size)
		#print(_coord, " ", point, " ", image_point)
		var existing_color := _image.get_pixelv(image_point)
		var new_color := color.blend(existing_color)
		_image.set_pixelv(image_point,new_color)
	_texture.update(_image)
	on_image_ready.call_deferred()

func on_image_ready():
	_thread.wait_to_finish()
	
func _process(delta: float) -> void:
	if _point_queue.size() > 0:
		update_map()
