class_name PaintMap
extends Node3D

enum BlendMode {
		SET,
		BLEND,
		MULTIPLY,
		ADD,
		SUBTRACT
	}

@export var texture_size : int = 128
@export var pixel_scale : float = 0.05

func draw_line(pos_a:Vector3,pos_b:Vector3,width:float=1.0,color:Color=Color.WHITE, blend:BlendMode=BlendMode.BLEND):
	pass

func draw_circle(pos:Vector3,radius:float,color:Color=Color.WHITE, blend:BlendMode=BlendMode.BLEND):
	pass

func draw_point(pos:Vector3,color:Color=Color.WHITE, blend:BlendMode=BlendMode.BLEND):
	pass
