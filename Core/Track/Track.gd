class_name Track
extends Line3D


@export var min_segment_length : float = 0.1
@export var lifetime : float = 60.0
@export var max_idle_time : float = 60.0

var _point_ages : Array[float]
var _point_colors : Array[Color]
var _idle_time : float

signal expired

func add_point(pos:Vector3,normal:Vector3,width:float,color:=Color.WHITE):
	var point_count := get_point_count()
	var new_point := to_local(pos)
	if point_count > 2:
		var last_p := point_count-1
		var previous_p := last_p-1
		var last_position :=  get_point_position(last_p)
		var previous_position := get_point_position(previous_p)
		var last_segment_length := (last_position - previous_position).length()
		if last_segment_length < min_segment_length:
			set_point_position(last_p, new_point)
			set_point_age(last_p,0.0)
			var new_segment_length := (new_point - previous_position).length()
			set_point_t(last_p,get_point_t(previous_p)+new_segment_length)
			return
	super.add_point(pos,normal,width,color)
	_point_ages.append(0.0)
	_point_colors.append(color)
	_idle_time = 0.0
	
func remove_point(idx:int):
	super.remove_point(idx)
	_point_ages.remove_at(idx)
	_point_colors.remove_at(idx)

func set_point_age(idx:int,age:float):
	_point_ages[idx] = age
	_rebuild_queued = true

func _process(delta):
	super._process(delta)
	update_points()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_idle_time += delta
	for p in range(_points.size()):
		_point_ages[p] += delta
	if _idle_time > lifetime:
		expired.emit()
		queue_free()

func update_points():
	var point_count := get_point_count()
	if point_count == 0:
		return
	
	while _point_ages[0] > lifetime:
		remove_point(0)
