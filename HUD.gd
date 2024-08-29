class_name HUD
extends CanvasLayer

@export var character : Character

#@export var slot_tool_panels : Array[ToolPanel]
#@export var slot_equipment_panels : Array[ToolPanel]
@export var inventory_display: InventoryDisplay
@export var interactions_display : InteractionsDisplay
@export var tool_display : ToolDisplay
@export var equipment_display : ToolDisplay
@export var character_panel : CharacterHUDPanel
@export var character_hud_overlay : CharacterHUDOverlay
@export var vehicle_panel : VehicleHUDPanel

func _ready():
	tool_display.tool_user = character.tool_user
	equipment_display.tool_user = character.equipment_user
	inventory_display.inventory = character.inventory
	interactions_display.interactor = character.interactor
	
	character.controller.hover_object_changed.connect(on_hover_changed)
	character.mount_changed.connect(on_mount_changed)

	character_panel.character = character

func on_hover_changed(object:Node3D):
	if is_instance_valid(object):
		character_hud_overlay.visible = true
		if object is Character:
			character_hud_overlay.character = object
		else:
			character_hud_overlay.visible = false
	else:
		character_hud_overlay.visible = false

func on_mount_changed(mount:Mount):
	vehicle_panel.vehicle = mount.vehicle if is_instance_valid(mount) else null
