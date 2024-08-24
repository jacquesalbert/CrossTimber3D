class_name DismountInteraction
extends Interaction

@export var mount : Mount

func interact(character:Character):
	mount.dismount(character)
