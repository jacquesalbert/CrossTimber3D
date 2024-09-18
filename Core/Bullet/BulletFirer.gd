class_name BulletFirer
extends Node3D

@export var bullet_scene : PackedScene
#@export var damage : int = 10
#@export var speed : float = 1000
#@export var speed_variation : float = 100.0
#@export var speed_minimum : float = 200.0
#@export var range : float = 100
#@export var range_variation : float = 50
@export_range(0.0,TAU) var angle_spread : float = TAU
#@export var stability : float = 0.95
@export var count : int = 1
#@export var recoil : float = 1
#@export_flags_3d_physics var bullet_collision_mask : int
#@export var trail_gradient : Gradient
#@export var trail_lifetime : float = 0.1
#@export var trail_width : float = 1.0
#@export var bullet_trailer_scene : PackedScene
#@export var material_hit_effects: Dictionary
#@export var apply_effects: Array[PackedScene]

var queue_fire : bool

var responsible_node : Node
var exceptions : Array[CollisionObject3D]

func add_exception(exception:CollisionObject3D):
	if not exceptions.has(exception):
		exceptions.append(exception)

func remove_exception(exception:CollisionObject3D):
	exceptions.erase(exception)

func fire():
	if is_inside_tree():
		_fire_bullets()
	else:
		queue_fire = true

func _fire_bullet():
	var angle := (randf() - 0.5)*angle_spread
	#var target_dir := global_basis * Vector3((randf() - 0.5)*angle_spread,0.0,1.0).normalized()
	var bullet_instance : Bullet= bullet_scene.instantiate()
	bullet_instance.transform = global_transform.rotated_local(Vector3.UP,angle)
	bullet_instance.position = global_position
	bullet_instance.responsible_node = responsible_node


	LevelManager.spawn_in_level(bullet_instance)
	for exception in exceptions:
		bullet_instance.add_exception(exception)

func _fire_bullets():
	for i in range(count):
		_fire_bullet()
		
func _physics_process(delta):
	if queue_fire:
		_fire_bullets()
		queue_fire = false
