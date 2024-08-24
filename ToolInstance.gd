class_name ToolInstance
extends Node3D

#var target_distance:float

var triggered : bool = false

var character:Character
#var cover_exceptions : Array[CollisionObject2D]

signal fired

func on_equip():
	pass

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
