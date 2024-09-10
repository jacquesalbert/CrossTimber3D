class_name BulletFirer
extends Node3D

@export var damage : int = 10
@export var speed : float = 1000
@export var speed_variation : float = 100.0
@export var speed_minimum : float = 200.0
@export var range : float = 100
@export var range_variation : float = 50
@export_range(0.0,TAU) var angle_spread : float = TAU
@export var stability : float = 0.95
@export var count : int = 1
#@export var recoil : float = 1
@export_flags_3d_physics var bullet_collision_mask : int
#@export var trail_gradient : Gradient
#@export var trail_lifetime : float = 0.1
#@export var trail_width : float = 1.0
@export var bullet_trailer_scene : PackedScene
@export var material_hit_effects: Dictionary
@export var apply_effects: Array[PackedScene]

@export var queue_fire : bool

var responsible_node : Node
var exceptions : Array[CollisionObject3D]

func fire():
	queue_fire = true

func _fire_bullet():
	var target_dir := global_basis * Vector3.FORWARD.normalized().rotated(Vector3.UP,(randf() - 0.5)*2*angle_spread)
	var bullet_speed :float = max(speed_minimum,randfn(speed, speed_variation))
	var bullet_range := randfn(range, range_variation)
	var bullet := Bullet.new(target_dir, bullet_speed, stability, damage, bullet_range, responsible_node, bullet_collision_mask)
	bullet.apply_effects = apply_effects
	for exception in exceptions:
		bullet.add_exception(exception)

	#for cover_exception in cover_exceptions:
		#bullet.add_exception(cover_exception)
	bullet.material_hit_effects = material_hit_effects

	LevelManager.spawn_in_level(bullet)
	bullet.global_position = global_position
	if is_instance_valid(bullet_trailer_scene):
		var trailer := bullet_trailer_scene.instantiate()
		bullet.add_child(trailer)
		trailer.enable()

func _physics_process(delta):
	if queue_fire:
		for i in range(count):
			_fire_bullet()
		queue_fire = false
