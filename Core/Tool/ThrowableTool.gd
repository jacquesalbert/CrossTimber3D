extends ToolInstance

@export var projectile_scene : PackedScene

@export_range(0.0,TAU) var angle_spread : float = 0.0

@export var count : int = 1

@export var throw_stream : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_equip():
	super.on_equip()

func on_unequip():
	super.on_unequip()

func attack():
	if not $Timer.is_stopped():
		return

	for i in range(count):
		throw_projectile()

	streamplayer.stream = throw_stream
	streamplayer.play()
	fired.emit()

	$Timer.start()


func throw_projectile():
	var target_dir := global_basis * Vector3((randf() - 0.5)*angle_spread,PI/4,1.0).normalized()

	var projectile : SimpleProjectile= projectile_scene.instantiate()
	projectile.position = global_position
	projectile.velocity = target_dir * 10
	LevelManager.spawn_in_level(projectile)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if triggered:
		attack()
