class_name PlayerController
extends Controller

@export_flags_3d_physics var cursor_mask : int
@export var max_cursor_distance : float = 100
@export var camera : Camera3D

var hover_object : Node3D:
	set(value):
		if value != hover_object:
			hover_object = value
			hover_object_changed.emit(hover_object)

var mouse_point : Vector3
var mounted : bool:
	set(value):
		if mounted != value:
			mounted = value
			if mounted:
				set_camera_mounted()
			else:
				set_camera_dismounted()

signal hover_object_changed(object:Node2D)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func set_camera_mounted():
	camera.size = 80

func set_camera_dismounted():
	camera.size = 40

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_universal_controls(delta)
	if mounted:
		update_mounted_controls(delta)
	else:
		update_dismounted_controls(delta)

func update_universal_controls(delta:float):
	aim_point = mouse_point - global_position

	if Input.is_action_just_pressed("ui_page_up"):
		Engine.time_scale *= 2.0
		print("Time scale: " + str(Engine.time_scale))
	if Input.is_action_just_pressed("ui_page_down"):
		Engine.time_scale *= 0.5
		print("Time scale: " + str(Engine.time_scale))
	if Input.is_action_just_pressed("cycle_interaction"):
		cycle_interaction.emit()
	if Input.is_action_just_pressed("interact"):
		interact.emit()
	if Input.is_action_just_pressed("use_tool"):
		trigger_tool_on.emit()
	elif Input.is_action_just_released("use_tool"):
		trigger_tool_off.emit()
	
	if Input.is_action_just_pressed("cycle_tool"):
		cycle_tool.emit()
	
	if Input.is_action_just_pressed("cycle_equipment"):
		cycle_equipment.emit()

	if Input.is_action_just_pressed("use_equipment"):
		trigger_equipment_on.emit()
	elif Input.is_action_just_released("use_equipment"):
		trigger_equipment_off.emit()

func get_mouse_info():
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
		mouse_point = result['position']
	if result.has('collider'):
		hover_object = result['collider']
	else:
		hover_object = null

func update_dismounted_controls(delta:float):
	run = Input.is_action_pressed("run")
	
	movement = Input.get_vector("move_right","move_left","move_back","move_forward")

func update_mounted_controls(delta:float):
	traction_control = not Input.is_action_pressed("run")
	steer = Input.get_axis("move_left","move_right")
	throttle = Input.get_axis("move_back","move_forward")
	brake = 1.0 if Input.is_action_pressed("ui_accept") else 0.0

func _physics_process(delta):
	get_mouse_info()
