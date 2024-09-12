class_name MatchFrames
extends Sprite3D

var _mirror_sprite:Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready():
	_mirror_sprite = get_parent()
	if _mirror_sprite:
		hframes = _mirror_sprite.hframes
		vframes = _mirror_sprite.vframes
	match_sprite()

func match_sprite():
	if _mirror_sprite:
		frame = _mirror_sprite.frame
		visible = _mirror_sprite.visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match_sprite()
