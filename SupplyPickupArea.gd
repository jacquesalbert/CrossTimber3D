class_name SupplyPickupArea
extends Area3D

@export var pickup : SupplyPickup
@export var item: Item
@export var quantity: int

signal amount_changed(amount:int)

func take(amount : int):
	quantity = max(quantity-amount,0)
	amount_changed.emit(quantity)
