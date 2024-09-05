class_name MountInteraction
extends Interaction

@export var mount : Mount

func interact(character:Character):
	mount.mount(character)
