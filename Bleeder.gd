class_name Bleeder
extends Node3D

@export var count :int = 1
@export var min_drop_radius : float = 0.5
@export var max_drop_radius : float = 1.5
@export var spread: float = 0.1
@export var squirt_velocity: float = 2.0
@export var color : Color = Color(0.7,0,0)
@export var auto_trigger : bool
@export_range(0.0,1.0) var chunkiness : float = 0.5

var _drop_positions : Array[Vector3]
var _drop_velocities : Array[Vector3]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if auto_trigger:
		spawn.call_deferred()

func _physics_process(delta: float) -> void:
	var gravity := 9.8 * Vector3.DOWN * delta
	var keep_drops : Array[Vector3]
	var keep_vels : Array[Vector3]
	for i in range(_drop_positions.size()):
		_drop_velocities[i] = _drop_velocities[i] + gravity
		_drop_positions[i] = _drop_positions[i] + _drop_velocities[i] * delta
		if _drop_positions[i].y < 0:
			LevelManager.current_level.paint_map.set_circle(_drop_positions[i],randf_range(min_drop_radius,max_drop_radius),color.blend(Color(randf(),0,0,randf_range(0.0,chunkiness))))
		else:
			keep_drops.append(_drop_positions[i])
			keep_vels.append(_drop_velocities[i])
	_drop_positions = keep_drops
	_drop_velocities = keep_vels

func spawn(spawn_count:int=1):
	var total_spawn_count := spawn_count*count
	for i in range(total_spawn_count):
		_drop_positions.append(global_position)
		#var spawn_velocity := randf()*spread*Vector3.FORWARD.rotated(Vector3.UP,randf()*TAU).rotated(Vector3.RIGHT,(randf()-.5)*PI)
		##spawn_velocity = Vector3.ZERO
		#var squirt_vel := randf()*Vector3.MODEL_FRONT *squirt_velocity
		var velocity := global_basis.z * randf() * squirt_velocity
		velocity = velocity.rotated(global_basis.x,randfn(0.0,1.0)*PI/8)
		velocity = velocity.rotated(global_basis.y,randfn(0.0,1.0)*PI/16)
		_drop_velocities.append(velocity)
