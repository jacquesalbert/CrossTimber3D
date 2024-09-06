class_name Tool
extends Resource

enum Category {
	WEAPON,
	EQUIPMENT
}

enum Type {
	UNARMED,
	MELEE,
	SIDEARM,
	LONGARM,
	THROWN
}

@export var text : String
@export var description: String
@export var icon: Texture2D
@export var category : Category
@export var type : Type
@export var instance : PackedScene

@export var consumable : bool
#@export var consumes_supply : bool
#@export var supply : Item
#@export var supply_amount : int = 1
@export var recoil : float

@export var has_pickup : bool
@export var pickup_graphics : PackedScene
@export var pickup_sound : AudioStream
@export var equip_sound : AudioStream
@export var drop_sound : AudioStream

func get_pickup()->ToolPickup:
	if has_pickup:
		var pickup :ToolPickup = load("res://Core/Tool/tool_pickup_template.tscn").instantiate()
		pickup.tool = self
		return pickup
	return null
