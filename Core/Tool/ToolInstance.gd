class_name ToolInstance
extends Node3D

#var target_distance:float
@export var equip_stream : AudioStream
@export var streamplayer : AudioStreamPlayer3D

var triggered : bool = false

var character:Character
#var cover_exceptions : Array[CollisionObject2D]

signal fired

func set_character(character:Character):
	self.character=character

func on_equip():
	streamplayer.stream = equip_stream
	streamplayer.play()

func on_unequip():
	pass

func trigger():
	triggered = true

func untrigger():
	triggered = false

#func attach_model(attach_node:Node2D):
	#if model:
		#model.reparent(attach_node,false)
#
#func detach_model():
	#if model:
		#model.reparent(self)

#func consume_item(item:Item, quantity:int)->bool:
	#return self.tool_user.consume_item(item,quantity)
