class_name SupplyArea
extends Area3D

@export var inventory : Inventory

func _ready():
	area_entered.connect(on_area_entered)

func enable():
	process_mode = Node.PROCESS_MODE_INHERIT

func disable():
	process_mode = Node.PROCESS_MODE_DISABLED

func on_area_entered(area:Area3D):
	if area is SupplyPickupArea:
		try_pickup(area)

func check_pickup():
	for area in get_overlapping_areas():
		if area is SupplyPickupArea:
			try_pickup(area)

func try_pickup(area:SupplyPickupArea):
	var supply_pickup :SupplyPickupArea = area
	var added := inventory.add_items(supply_pickup.item,supply_pickup.quantity)
	supply_pickup.take(added)
