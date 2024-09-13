extends ToolInstance

@export var projectile_scene : PackedScene

@export_flags_3d_physics var projectile_mask : int = 1
@export_range(0.0,TAU) var angle_spread : float = 0.0
#@export var speed : float = 10.0

@export var count : int = 1

@export var throw_stream : AudioStream

func on_equip():
	super.on_equip()

func on_unequip():
	super.on_unequip()

func attack():
	if not ready_to_fire:
		return

	for i in range(count):
		throw_projectile()

	streamplayer.stream = throw_stream
	streamplayer.play()
	fired.emit()
	timer.start()
	set_not_ready_to_fire()


func throw_projectile():
	var g := 9.8
	var num := target_distance*target_distance*g
	var denom := target_distance + 2 * global_position.y
	var throw_velocity := sqrt(num/denom)
	var projectile : SimpleProjectile= projectile_scene.instantiate()
	projectile.position = global_position
	projectile.velocity = global_basis.z.rotated(-global_basis.x,PI/4) * throw_velocity
	projectile.set_responsible_node(character)
	LevelManager.spawn_in_level(projectile)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if triggered:
		attack()
