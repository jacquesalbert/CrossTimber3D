class_name SupplyPickup
extends Pickup

#@export var model:Node3D
@export var item : Item
@export var quantity : int
@export var supply_pickup_area : SupplyPickupArea
#@export var pickup_stream : AudioStreamPlayer2D
#@export var drop_stream : AudioStreamPlayer2D
@export var stream_player : AudioStreamPlayer3D

var _graphics : Node3D

func _ready():
	super._ready()
	init_from_item(item)
	supply_pickup_area.pickup = self
	supply_pickup_area.amount_changed.connect(update_quantity)
	stream_player.stream = item.drop_sound
	stream_player.play()

func init_from_item(item:Item):
	if not item or quantity <= 0:
		queue_free()
		return
	supply_pickup_area.item = item
	update_quantity(quantity)
	
func update_quantity(new_quantity:int):
	#sprite.texture = item.get_pickup_sprite(quantity)
	if is_instance_valid(_graphics):
		_graphics.queue_free()
	_graphics = item.get_pickup_graphics(new_quantity)
	add_child(_graphics)
	supply_pickup_area.quantity = new_quantity
	if quantity != new_quantity:
		stream_player.stream = item.pickup_sound
		stream_player.play()
	if new_quantity <= 0:
		stream_player.reparent(get_tree().root)
		stream_player.finished.connect(stream_player.queue_free)
		queue_free()
	quantity = new_quantity
	
