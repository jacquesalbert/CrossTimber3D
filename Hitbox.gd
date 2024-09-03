class_name Hitbox
extends Area3D

@export_range(0,1) var hit_chance : float = 1.0
#@export var penetration_resistance : float = 0.0
@export var stability_reduction : float = 1.0
@export var damage_reduction : int = 5

signal was_hit(amount:int, hit_by:Node)

var default_collision_layer : int

# Called when the node enters the scene tree for the first time.
func _ready():
	default_collision_layer = collision_layer

func enable():
	collision_layer = default_collision_layer

func disable():
	collision_layer = 0

func hit(amount:int,hit_by:Node)->Dictionary:
	var hit := false
	var hit_roll := randf()
	#print_debug(hit_roll,"/", hit_chance)
	if hit_roll <= hit_chance:
		was_hit.emit(amount, hit_by)
		hit = true 
	return {
		"hit" : hit,
		"stability_modify" : -stability_reduction,
		"damage_modify" : -damage_reduction
		}
