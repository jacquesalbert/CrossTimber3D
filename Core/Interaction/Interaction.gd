class_name Interaction
extends Node

@export var text : String = "Interaction"
@export var icon : Texture2D

func interact(character:Character):
	print(character, " interacts with ", self)
