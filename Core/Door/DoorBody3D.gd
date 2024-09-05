class_name DoorBody3D
extends RigidBody3D

@export_flags_3d_physics var open_collision : int
@onready var closed_collison : int = collision_layer
@onready var _closed_rotation : Vector3 = rotation
@export var open_stream : AudioStream
@export var close_stream : AudioStream
@export var streamplayer : AudioStreamPlayer3D

enum State {
	OPEN,
	CLOSED
}

var _state : State = State.CLOSED

signal door_opened
signal door_closed

func open(from_position:Vector3):
	freeze = false
	_state = State.OPEN
	collision_layer = open_collision
	var side := global_basis.x.cross(from_position-global_position)
	apply_torque(Vector3.UP*100.0*-sign(side))
	door_opened.emit()
	streamplayer.stream = open_stream
	streamplayer.play()

func close():
	freeze = true
	rotation = _closed_rotation
	collision_layer = closed_collison
	_state = State.CLOSED
	door_closed.emit()
	streamplayer.stream = close_stream
	streamplayer.play()

func toggle_open(from_position:Vector3):
	if _state == State.OPEN:
		close()
	elif _state == State.CLOSED:
		open(from_position)

func _ready() -> void:
	close()
