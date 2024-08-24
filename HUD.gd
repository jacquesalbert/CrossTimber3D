class_name HUD
extends CanvasLayer

@export var character : Character

@export var slot_tool_panels : Array[ToolPanel]
@export var slot_equipment_panels : Array[ToolPanel]
@export var inventory_container : VBoxContainer
@export var interactions_container : VBoxContainer
@export var effects_panel : PanelContainer
@export var effects_container : HBoxContainer
@export var traits_panel : PanelContainer
@export var traits_container : VBoxContainer
@export var character_hud_overlay : CharacterHUDOverlay


var _item_panels : Dictionary

func _ready():
	$CharacterStatVBoxContainer/HealthStatPanel.stat = character.health
	$CharacterStatVBoxContainer/EnergyStatPanel.stat = character.energy
	for i in range(slot_tool_panels.size()):
		slot_tool_panels[i].slot = i
		slot_tool_panels[i].tool_user = character.tool_user
	for i in range(slot_equipment_panels.size()):
		slot_equipment_panels[i].slot = i
		slot_equipment_panels[i].tool_user = character.equipment_user
	
	character.inventory.contents_changed.connect(on_inventory_changed)
	for item in character.inventory.max_item_capacity:
		var item_panel :InventoryItemPanel = load("res://inventory_item_panel.tscn").instantiate()
		inventory_container.add_child(item_panel)
		item_panel.item = item
		item_panel.quantity = character.inventory.get_item_quantity(item)
		_item_panels[item] = item_panel
	
	character.controller.hover_object_changed.connect(on_hover_changed)
	character.mount_changed.connect(on_mount_changed)
	character.interactor.interactions_changed.connect(on_interactions_changed)
	character.interactor.selected_interaction_changed.connect(on_selected_interaction_changed)
	
	character.effects_changed.connect(on_effects_changed)
	on_effects_changed()
	character.traits_changed.connect(on_traits_changed)
	on_traits_changed()

func on_effects_changed():
	for child in effects_container.get_children():
		child.queue_free()
	effects_panel.visible = false
	for effect in character.current_effects:
		effects_panel.visible = true
		var effect_rect := TextureRect.new()
		effect_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		effect_rect.texture = effect.icon
		effects_container.add_child(effect_rect)

func on_traits_changed():
	for child in traits_container.get_children():
		child.queue_free()
	traits_panel.visible = false
	for _trait in character.current_traits:
		traits_panel.visible = true
		var trait_label := Label.new()
		trait_label.text = _trait.text
		traits_container.add_child(trait_label)

func on_selected_interaction_changed():
	var selected_interaction :Interaction= character.interactor.get_selected_interaction()
	for child in interactions_container.get_children():
		if child.interaction == selected_interaction:
			child.selected = true
		else:
			child.selected = false

func on_interactions_changed(interactions:Array[Interaction]):
	for child in interactions_container.get_children():
		child.visible = false
		child.queue_free()
	for interaction in interactions:
		var interaction_panel :InteractionPanelContainer = load("res://interaction_panel_container.tscn").instantiate()
		interactions_container.add_child(interaction_panel)
		interaction_panel.interaction = interaction
	on_selected_interaction_changed()

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
	#$VehicleStatVBoxContainer/HealthStatPanel.stat = character.mount.vehicle.health
	if mount is VehicleControlMount:
		$VehicleStatVBoxContainer/EnergyStatPanel.stat = mount.vehicle.fuel
		$VehicleStatVBoxContainer/HealthStatPanel.stat = mount.vehicle.health

func _process(delta):
	pass

func on_inventory_changed():
	for item in _item_panels:
		_item_panels[item].quantity = character.inventory.get_item_quantity(item)
