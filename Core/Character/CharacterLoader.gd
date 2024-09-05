class_name CharacterLoader
extends Node

@export var tools : Array[Tool]
@export var equipment : Array[Tool]
@export var supplies : Array[Item]:
	set(value):
		supplies = value
		supply_quantity.resize(supplies.size())
@export var supply_quantity : Array[int]
@export var body : Texture2D
@export var outfit : Texture2D
@export var traits : Array[Trait]

func load_character(character:Character):
	var tool_user : SlotToolUser = character.tool_user
	for i in range(tools.size()):
		tool_user.set_slot_tool(i,tools[i])
		
	var equipment_user : SlotToolUser = character.equipment_user
	for i in range(equipment.size()):
		equipment_user.set_slot_tool(i,equipment[i])
	
	var inventory : Inventory = character.inventory
	for i in range(supplies.size()):
		inventory.add_items(supplies[i], supply_quantity[i])
	
	for child in get_children():
		child.reparent(character,false)
	
	var graphics : CharacterGraphics = character.graphics
	graphics.base_palette = body
	graphics.overlay_palette = outfit
