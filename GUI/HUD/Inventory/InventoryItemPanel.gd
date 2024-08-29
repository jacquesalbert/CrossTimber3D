class_name InventoryItemPanel
extends PanelContainer

@export var icon_rect : TextureRect
@export var fill_meter : ProgressBar
@export var label : Label
@export var quantity_label : Label

var item : Item:
	set(value):
		item = value
		on_item_changed()
		on_quantity_changed()

var quantity : int:
	set(value):
		quantity = value
		on_quantity_changed()

var max_quantity : int:
	set(value):
		max_quantity = value
		on_quantity_changed()

func on_item_changed():
	icon_rect.texture = item.icon
	label.text = item.text

func on_quantity_changed():
	fill_meter.max_value = max_quantity
	fill_meter.value = quantity
	quantity_label.text = str(quantity) 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
