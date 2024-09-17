class_name ToolInstance
extends Node3D

var target_distance:float
@export var equip_stream : AudioStream
@export var streamplayer : AudioStreamPlayer3D
@export var timer : Timer

var ready_to_fire : bool
var triggered : bool

var character:Character
#var cover_exceptions : Array[CollisionObject2D]

signal fired
signal failed

func _ready() -> void:
	timer.timeout.connect(set_ready_to_fire)
	set_ready_to_fire()

func set_target_distance(distance:float):
	target_distance = distance

func set_character(character:Character):
	self.character=character

func on_equip():
	streamplayer.stream = equip_stream
	streamplayer.play()

func on_unequip():
	pass

func set_ready_to_fire():
	ready_to_fire = true

func set_not_ready_to_fire():
	ready_to_fire = false
	timer.start()

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
