extends ToolInstance

@export var damage : int = 10
@export var fire_rate : float = 1.0
@export var speed : float = 250
@export var speed_variation : float = 0.0
@export var speed_minimum : float = 50.0
@export var range : float = 1000
@export var range_variation : float = 50
@export_range(0.0,TAU) var angle_spread : float = 0.0
@export var stability : float = 0.95
@export var count : int = 1
@export var supply : Item
@export var supply_amount : int
#@export var recoil : float = 1
@export_flags_3d_physics var bullet_collision_mask :int
#@export var trail_transparency : BaseMaterial3D.Transparency = BaseMaterial3D.Transparency.TRANSPARENCY_ALPHA
#@export var trail_shadow: GeometryInstance3D.ShadowCastingSetting = GeometryInstance3D.ShadowCastingSetting.SHADOW_CASTING_SETTING_OFF
#@export var trail_color : Color = Color.WHITE
#@export var trail_gradient : Gradient
#@export var trail_lifetime : float = 0.1
#@export var trail_width : float = 1.0
#@export var trail_width_curve : Curve
@export var bullet_trailer_scene : PackedScene
@export var material_hit_effects: Dictionary
@export var apply_effects: Array[PackedScene]

@export var stream_player : AudioStreamPlayer3D
@export var equip_stream : AudioStream
@export var fire_stream : AudioStream
@export var empty_stream : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_equip():
	stream_player.stream = equip_stream
	stream_player.play()

func on_unequip():
	pass

func attack():
	if not $Timer.is_stopped():
		return
	
	var fire := true
	var inventory:Inventory
	
	if supply:
		if is_instance_valid(self.character) and is_instance_valid(self.character.inventory):
			inventory = self.character.inventory
			if inventory.get_item_quantity(supply) < supply_amount:
				fire = false
		else:
			fire = false

	if fire:
		if supply:
			inventory.remove_items(supply,supply_amount)
		for i in range(count):
			fire_bullet()
		#$AnimationPlayer.play("fire")
		stream_player.stream = fire_stream
		stream_player.play()
		fired.emit()
		#$CameraShaker.add_trauma()
	else:
		stream_player.stream = empty_stream
		stream_player.play()
	$Timer.start()
		

func fire_bullet():
	var target_dir := global_basis * Vector3((randf() - 0.5)*angle_spread,0.0,1.0).normalized()
	var bullet_speed :float = max(speed_minimum,randfn(speed, speed_variation))
	var bullet_range := randfn(range, range_variation)
	var bullet := Bullet.new(target_dir, bullet_speed, stability, damage, bullet_range, self.character, bullet_collision_mask)
	bullet.apply_effects = apply_effects
	if is_instance_valid(character):
		bullet.add_exception(character.hitbox)
	#bullet.trail_transparency = trail_transparency
	#bullet.trail_shadow = trail_shadow
	#bullet.trail_width_curve = trail_width_curve
	#bullet.trail_color = trail_color
	#for cover_exception in cover_exceptions:
		#bullet.add_exception(cover_exception)
	bullet.material_hit_effects = material_hit_effects
	#bullet.z_index = -1
	LevelManager.spawn_in_level(bullet)
	bullet.global_position = global_position
	if is_instance_valid(bullet_trailer_scene):
		var trailer := bullet_trailer_scene.instantiate()
		bullet.add_child(trailer)
		trailer.enable()
	$AnimationPlayer.seek(0)
	$AnimationPlayer.play("fire")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if triggered:
		attack()
