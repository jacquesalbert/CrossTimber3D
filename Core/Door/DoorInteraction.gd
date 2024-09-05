class_name DoorInteraction
extends Interaction

@export var door : DoorBody3D

func interact(character:Character):
	door.toggle_open(character.global_position)

func close_text():
	text = "Close Door"

func open_text():
	text = "Open Door"

func _ready() -> void:
	door.door_closed.connect(open_text)
	door.door_opened.connect(close_text)
