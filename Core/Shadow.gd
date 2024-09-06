class_name Shadow
extends Sprite3D

var offset_dir:Vector3
@export var offset_amount : float = 0.1
var _mirror_sprite:Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready():
	_mirror_sprite = get_parent()
	var initial_offset := (global_position - _mirror_sprite.global_position)
	offset_dir = initial_offset.normalized()
	rotation = Vector3.ZERO
	scale = Vector3.ONE
	if _mirror_sprite:
		hframes = _mirror_sprite.hframes
		vframes = _mirror_sprite.vframes
		pixel_size = _mirror_sprite.pixel_size
		texture = _mirror_sprite.texture
	match_sprite()

func match_sprite():
	if _mirror_sprite:
		frame = _mirror_sprite.frame

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match_sprite()
	global_position = _mirror_sprite.global_position + offset_dir * offset_amount
