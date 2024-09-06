extends Node3D

@export var max_cursor_distance : float = 1000
@export var blood_map : BloodMap
@export_flags_3d_physics var cursor_mask : int

@export var paint_color : Color

var tracing : bool
var color : Color
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("use_tool"):
		if event.is_pressed():
			tracing = true
			color = paint_color
		elif event.is_released():
			tracing = false
	if event.is_action("use_equipment"):
		if event.is_pressed():
			tracing = true
			color = Color.TRANSPARENT
		elif event.is_released():
			tracing = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if tracing:
		update_map()

func update_map():
	var cam := get_viewport().get_camera_3d()
	var m_pos := get_viewport().get_mouse_position()
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * max_cursor_distance
	var world3d : World3D = get_world_3d()
	var space_state = world3d.direct_space_state
	
	if space_state == null:
		return
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, cursor_mask)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	if result.has('position'):
		blood_map.set_point(result['position'],color)
