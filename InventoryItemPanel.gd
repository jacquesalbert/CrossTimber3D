class_name InventoryItemPanel
extends PanelContainer

@export var icon_rect : TextureRect
@export var label : Label
@export var quantity_label : Label

var item : Item:
	set(value):
		item = value
		icon_rect.texture = item.icon
		label.text = item.text

var quantity : int:
	set(value):
		quantity = value
		on_quantity_changed()

func on_quantity_changed():
	quantity_label.text = ": " + str(quantity) 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
