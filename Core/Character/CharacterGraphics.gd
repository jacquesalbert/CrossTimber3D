class_name CharacterGraphics
extends Node3D

enum ToolType {
	UNARMED,
	MELEE,
	SIDEARM,
	LONGARM,
	THROWN
}

@export var animation_tree : AnimationTree
#@export var tool_attachment : Node2D
@export var upper_body : Sprite3D
@export var lower_body : Sprite3D
#@export var default_sprite : Texture2D
#@export var default_palette : Texture2D
#@export var empty_palette : Texture2D
@export var base_palette : Texture2D:
	set(value):
		base_palette = value
		update_sprite()
@export var overlay_palette : Texture2D:
	set(value):
		overlay_palette = value
		update_sprite()
@export var ground_material_footstep_streams : Dictionary
@export var gib_scene :PackedScene
@export var gib_textures :Array[Texture2D]

#var sprite_texture : Texture2D

var alive : bool:
	set(value):
		alive = value
		var alive_key := "dead"
		if alive:
			alive_key = "alive"
		#print(self, alive_key)
		animation_tree.set("parameters/AliveTransition/transition_request", alive_key)

var stunned : bool:
	set(value):
		stunned = value
		var stunned_key := "active"
		if stunned:
			stunned_key = "stunned"
		#print(self, alive_key)
		animation_tree.set("parameters/StunTransition/transition_request", stunned_key)

var mounted : bool:
	set(value):
		mounted = value
		var mounted_key := "unmounted"
		if mounted:
			mounted_key = "mounted"
		#print(self, mounted_key)
		#animation_tree.set("parameters/Lower Body Mounted Transition/transition_request", mounted_key)
var mount_forward_angle : float

var driving : bool:
	set(value):
		driving = value
		var driving_key := "not driving"
		if driving:
			driving_key = "driving"
		#print(self, driving_key)
		#animation_tree.set("parameters/Upper Body Driving Transition/transition_request", driving_key)


var movement : Vector2:
	set(value):
		movement = value
		#print(self, move)
		#print("move key, ", move_key)
		var speed := movement.length()
		animation_tree.set("parameters/LowerBodyMovement/blend_position", speed)
		animation_tree.set("parameters/UnarmedMovement/blend_position",speed)
		#lower_body.rotation.y = movement.angle() + PI
		#animation_tree.set("parameters/Lower Body Movement Transition/transition_request", move)
		#animation_tree.set("parameters/Upper Body Movement Transition/transition_request", move)
			
#var move_angle : float:
	#set(value):
		#move_angle = value
		

var tool : ToolType:
	set(value):
		tool = value
		var tool_string := "unarmed"
		match tool:
			ToolType.UNARMED:
				tool_string = "unarmed"
			ToolType.MELEE:
				tool_string = "melee"
			ToolType.SIDEARM:
				tool_string = "sidearm"
			ToolType.LONGARM:
				tool_string = "longarm"
			ToolType.THROWN:
				tool_string = "Thrown"
		#print(self, tool)
		#animation_tree.set("parameters/Lower Body Weapon Transition/transition_request", tool_string)
		animation_tree.set("parameters/WeaponTransition/transition_request", tool_string)

var exhaustion : float = 0.0:
	set(value):
		exhaustion = value
		#print(self, "breathe", exhaustion)
		#animation_tree.set("parameters/BreatheRate/scale", max(0.0,1.0+exhaustion))

var ground_material: String:
	set(value):
		if ground_material != value:
			ground_material = value
			#$FootstepAudioPlayer.stream = ground_material_footstep_streams.get(ground_material)

func activate_tool():
	animation_tree.set("parameters/FireUnarmedOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/FireMeleeOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/FireSidearmOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/FireLongarmOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func hurt(amount:int):
	if amount < 0:
		animation_tree.set("parameters/HurtOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

#func on_outfit_changed(from_outfit:Outfit, to_outfit:Outfit):
	#if to_outfit:
		#overlay_palette = to_outfit.overlay_palette
		#sprite_texture = to_outfit.sprite_texture
	#else:
		#overlay_palette = empty_palette
		#sprite_texture = default_sprite
	#update_sprite()

func _process(delta):
	pass
func _on_surface_changed(surface):
	ground_material = surface.effect_material if surface else ""

func update_sprite():
	pass
	#upper_body.texture = sprite_texture
	#lower_body.texture = sprite_texture
	#set_palettes(upper_body.material)
	#set_palettes(lower_body.material)

func set_palettes(shader_mat:ShaderMaterial):
	pass
	#shader_mat.set_shader_parameter("base_palette",base_palette)
	#shader_mat.set_shader_parameter("overlay_palette",overlay_palette)

func gib():
	upper_body.hide()
	lower_body.hide()
	for i in range(10):
		#print("gib")
		var gib_instance : SimpleProjectile= gib_scene.instantiate()
		var sprite := gib_instance.get_node("Sprite3D")
		sprite.texture = gib_textures.pick_random()
		#set_palettes(sprite.material)
		#gib_instance.global_rotation = randf() * TAU
		#gib_instance.angular_speed = randf() * 5.0
		#gib_instance.speed = randf_range(50,100)
		#gib_instance.target = global_position + Vector2.RIGHT.rotated(randf()*TAU) * randf() * 32.0
		
		gib_instance.position = global_position + Vector3.UP * 2
		gib_instance.rotation = Vector3(0,randf(),0)*TAU
		gib_instance.angular_velocity = randf() * 10
		gib_instance.velocity = Vector3.UP*10+Vector3.FORWARD.rotated(Vector3.UP,randf()*TAU)*randf_range(0,2)
		LevelManager.spawn_in_level(gib_instance)
		#gib_instance.apply_impulse(*randf_range(1,5),Vector3.FORWARD.rotated(Vector3.UP,randf()*TAU))
	
# Called when the node enters the scene tree for the first time.
func _ready():
	overlay_palette = load("res://Resources/person_palettes/empty_palette.png")
	update_sprite()
