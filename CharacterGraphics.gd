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
@export var upper_body : Sprite2D
@export var lower_body : Sprite2D
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
		animation_tree.set("parameters/Dead Transition/transition_request", alive_key)

var mounted : bool:
	set(value):
		mounted = value
		var mounted_key := "unmounted"
		if mounted:
			mounted_key = "mounted"
		animation_tree.set("parameters/Lower Body Mounted Transition/transition_request", mounted_key)
var mount_forward_angle : float

var driving : bool:
	set(value):
		driving = value
		var driving_key := "not driving"
		if driving:
			driving_key = "driving"
		animation_tree.set("parameters/Upper Body Driving Transition/transition_request", driving_key)


var move : String:
	set(value):
		move = value
		if move == "walk":
			$FootstepAudioPlayer.volume_db = -9
		elif move == "run":
			$FootstepAudioPlayer.volume_db = 0
		animation_tree.set("parameters/Lower Body Movement Transition/transition_request", move)
		animation_tree.set("parameters/Upper Body Movement Transition/transition_request", move)
			
var move_angle : float:
	set(value):
		move_angle = value
		lower_body.rotation = value

var tool : ToolType:
	set(value):
		tool = value
		var tool_string := "Unarmed"
		match tool:
			ToolType.UNARMED:
				tool_string = "Unarmed"
			ToolType.MELEE:
				tool_string = "Melee"
			ToolType.SIDEARM:
				tool_string = "Sidearm"
			ToolType.LONGARM:
				tool_string = "Longarm"
			ToolType.THROWN:
				tool_string = "Thrown"
		animation_tree.set("parameters/Lower Body Weapon Transition/transition_request", tool_string)
		animation_tree.set("parameters/Upper Body Weapon Transition/transition_request", tool_string)

var exhaustion : float = 0.0:
	set(value):
		exhaustion = value
		animation_tree.set("parameters/BreatheRate/scale", max(0.0,1.0+exhaustion))

var ground_material: String:
	set(value):
		if ground_material != value:
			ground_material = value
			$FootstepAudioPlayer.stream = ground_material_footstep_streams.get(ground_material)

func activate_tool():
#	animation_tree.set("parameters/Upper Body Unarmed Punch Oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/Upper Body Unarmed Attack Oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/Upper Body Melee Attack Oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/Upper Body Sidearm Recoil Oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/Upper Body Longarm Recoil Oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	animation_tree.set("parameters/Upper Body Throwable Throw Oneshot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

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
	#upper_body.texture = sprite_texture
	#lower_body.texture = sprite_texture
	set_palettes(upper_body.material)
	set_palettes(lower_body.material)

func set_palettes(shader_mat:ShaderMaterial):
	shader_mat.set_shader_parameter("base_palette",base_palette)
	shader_mat.set_shader_parameter("overlay_palette",overlay_palette)

func gib():
	pass
	#upper_body.hide()
	#lower_body.hide()
	#for i in range(10):
		#var gib_instance := gib_scene.instantiate()
		#var sprite := gib_instance.get_node("Sprite2D")
		#sprite.texture = gib_textures.pick_random()
		#set_palettes(sprite.material)
		#gib_instance.global_position = global_position
		#gib_instance.global_rotation = randf() * TAU
		#gib_instance.angular_speed = randf() * 5.0
		#gib_instance.speed = randf_range(50,100)
		#gib_instance.target = global_position + Vector2.RIGHT.rotated(randf()*TAU) * randf() * 32.0
		#LevelManager.spawn_in_level(gib_instance)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	overlay_palette = load("res://Resources/person_palettes/empty_palette.png")
	update_sprite()
