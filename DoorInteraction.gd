class_name DoorInteraction
extends Interaction

@export var door : DoorBody3D

func interact(character:Character):
	door.toggle_open(character.global_position)

func update_text(new_state:DoorBody3D.State):
	match new_state:
		DoorBody3D.State.CLOSED:
			text = "Open Door"
		DoorBody3D.State.OPEN:
			text = "Close Door"

func _ready() -> void:
	door.state_changed.connect(update_text)
