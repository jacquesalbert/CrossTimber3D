class_name InventoryDisplay
extends VBoxContainer

const ITEM_PANEL_SCENE := preload("res://GUI/HUD/Inventory/inventory_item_panel.tscn")

var _item_panels : Dictionary

var inventory : Inventory:
	set(value):
		inventory = value
		inventory.contents_changed.connect(on_inventory_changed)
		for item in inventory.max_item_capacity:
			var panel :InventoryItemPanel = ITEM_PANEL_SCENE.instantiate()
			add_child(panel)
			panel.item = item
			panel.max_quantity = inventory.get_item_capacity(item)
			panel.quantity = inventory.get_item_quantity(item)
			_item_panels[item] = panel


func on_inventory_changed():
	for item in _item_panels:
		_item_panels[item].max_quantity = inventory.get_item_max_capacity(item)
		_item_panels[item].quantity = inventory.get_item_quantity(item)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
