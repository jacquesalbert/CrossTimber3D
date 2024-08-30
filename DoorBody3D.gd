class_name DoorBody3D
extends RigidBody3D

@export_flags_3d_physics var open_collision : int
@onready var closed_collison : int = collision_layer
@onready var _closed_rotation : Vector3 = rotation

enum State {
	OPEN,
	CLOSED
}

var _state : State = State.CLOSED

signal state_changed(new_state:State)

func open(from_position:Vector3):
	freeze = false
	_state = State.OPEN
	collision_layer = open_collision
	var side := global_basis.x.cross(from_position-global_position)
	apply_torque(Vector3.UP*100.0*-sign(side))
	state_changed.emit(_state)

func close():
	freeze = true
	rotation = _closed_rotation
	collision_layer = closed_collison
	_state = State.CLOSED
	state_changed.emit(_state)

func toggle_open(from_position:Vector3):
	if _state == State.OPEN:
		close()
	elif _state == State.CLOSED:
		open(from_position)

func _ready() -> void:
	close()
