class_name Mount
extends Node3D

@export var vehicle:RigidBodyVehicle
@export var dismount_point : Node3D
@export var control : bool

var interactions : Array[Interaction]

func _ready():
	for child in get_children():
		if child is Interaction:
			interactions.append(child)

func mount(character:Character):
	character.mount(self)

func dismount(character:Character):
	character.dismount(self)
