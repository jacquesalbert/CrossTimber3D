class_name Stat
extends Node

@export var max_value : int = 100
@export var allow_negative : bool

var value : int

signal changed(amount:int, responsible_node:Node)
signal expended(responsible_node:Node)

# Called when the node enters the scene tree for the first time.
func _ready():
	value = max_value

func modify(amount:int, responsible_node:Node):
	var start_value := value
	value += amount
	if value < 0 and not allow_negative:
		value = 0
	changed.emit(amount,responsible_node)
	
	if start_value > 0 and value <= 0:
		expended.emit(responsible_node)
