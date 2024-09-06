extends Resource
class_name Item

@export var text: String
@export var description: String
@export var icon: Texture2D
@export var pickup_sound: AudioStream
@export var drop_sound: AudioStream

@export var stack_size: int = 1

@export var single_pickup_graphics : PackedScene
@export var partial_stack_pickup_graphics : PackedScene
@export var full_stack_pickup_graphics : PackedScene

#func use(user:Character):
	#print_debug(user, " used ", text)

func on_pickup(user:Character):
	print_debug(user, " picked up ", text)

func on_drop(user:Character):
	print_debug(user, " dropped ", text)

func get_pickups(quantity:int)->Array[SupplyPickup]:
	var quantity_remaining := quantity
	var pickups : Array[SupplyPickup]
	while quantity_remaining > 0:
		var pickup_quantity :int= min(quantity_remaining, stack_size)
		var pickup :SupplyPickup = load("res://Core/Supply/supply_pickup_template.tscn").instantiate()
		pickup.item = self
		pickup.quantity = pickup_quantity
		pickup.init_from_item(self)
		quantity_remaining -= pickup_quantity
		pickups.append(pickup)
	return pickups

func get_pickup_graphics(quantity:int)->Node3D:
	if quantity >= stack_size:
		return full_stack_pickup_graphics.instantiate()
	if quantity > 1:
		return partial_stack_pickup_graphics.instantiate()
	if quantity > 0:
		return single_pickup_graphics.instantiate()
	return null

#func get_equipment():
	#var equipment_instance := equipment.instantiate()
	#if equipment_instance and consumable:
		#equipment_instance.ammo_item = self
	#return equipment_instance

#func create_pickup(quantity:int=1)->PickupProp:
	#var pickup_template := preload("res://Pickups/PickupTemplate.tscn")
	#var pickup_prop :PickupProp= pickup_template.instantiate()
	#pickup_prop.init_from_item(self, quantity)
	#return pickup_prop
