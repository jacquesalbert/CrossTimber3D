class_name LinearPaintMap
extends PaintMap

const CHUNK_DIRECTIONS := [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT, Vector2i.LEFT+Vector2i.UP,Vector2i.RIGHT+Vector2i.UP,Vector2i.LEFT+Vector2i.DOWN,Vector2i.RIGHT+Vector2i.DOWN]

@export var base_material : StandardMaterial3D

var _chunk_mesh_dictionary : Dictionary
var _mesh_size : float
var _half_mesh_size : float
var _chunk_pixel_size : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_chunk_pixel_size = texture_size - 2
	_mesh_size = _chunk_pixel_size * pixel_scale
	_half_mesh_size = _mesh_size * 0.5
	
func chunk_coord(point_coord : Vector2i)->Vector2i:
	return Vector2i(floor(float(point_coord.x)/_chunk_pixel_size), floor(float(point_coord.y)/_chunk_pixel_size))

func get_point_chunks(pos:Vector3)->Array[PaintMapChunk]:
	var pos_2d : Vector2 = Vector2(pos.x,pos.z)
	var point_coord : Vector2i = Vector2i(floor(pos_2d.x/pixel_scale), floor(pos_2d.y/pixel_scale))
	#print("pc: ", point_coord)
	#print("point_coord: ", point_coord)
	var point_chunk_coord := chunk_coord(point_coord)
	#print("cc: ", point_chunk_coord)
	var chunk_coords : Array[Vector2i] = [point_chunk_coord]
	#print("chunk_coord: ", point_chunk_coord)
	for dir in CHUNK_DIRECTIONS:
		#var point_coord :Vector2i= floor(pos_2d)
		var dir_point : Vector2= point_coord + dir
		#if dir == Vector2i.DOWN:
			#print(pos_2d, dir, dir_point)
		var dir_point_chunk := chunk_coord(dir_point)
		if not chunk_coords.has(dir_point_chunk):
			chunk_coords.append(dir_point_chunk)

	var chunks : Array[PaintMapChunk]
	
	for chunk_coord in chunk_coords:
		if _chunk_mesh_dictionary.has(chunk_coord):
			var chunk : PaintMapChunk = _chunk_mesh_dictionary[chunk_coord]
			chunks.append(chunk)
		else:
			var chunk : PaintMapChunk = PaintMapChunk.new(chunk_coord,pixel_scale,texture_size,_mesh_size)
			chunk._material = base_material.duplicate()
			#chunk._thread = _thread
			#chunk._mutex = _mutex
			#chunk.mesh_size = mesh_size
			#chunk.pixel_scale = pixel_scale
			chunk.position = Vector3(chunk_coord.x, 0, chunk_coord.y) * _mesh_size + Vector3(_half_mesh_size, 0, _half_mesh_size)
			add_child(chunk)
			_chunk_mesh_dictionary[chunk_coord] = chunk
			chunks.append(chunk)
	
	return chunks

func set_line(pos_a:Vector3,pos_b:Vector3,width:float=1.0,color:Color=Color.WHITE):
	var chunks := get_point_chunks(pos_a)
	chunks.append_array(get_point_chunks(pos_b))
	for chunk in chunks:
		chunk.set_line(pos_a,pos_b,width,color.srgb_to_linear())

func set_circle(pos:Vector3,radius:float,color:Color=Color.WHITE):
	var chunks := get_point_chunks(pos)
	for chunk in chunks:
		chunk.set_circle(pos,radius,color.srgb_to_linear())

func set_point(pos:Vector3,color:Color=Color.WHITE):
	var chunks := get_point_chunks(pos)
	for chunk in chunks:
		chunk.set_point(pos,color.srgb_to_linear())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
