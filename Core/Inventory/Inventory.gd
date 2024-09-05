extends Node
class_name Inventory

#enum InventoryResult {
	#ADDED_SUCCESSFULLY,
	#REMOVED_SUCCESSFULLY,
	#INVENTORY_FULL,
	#ITEM_NOT_FOUND,
#}

@export var max_item_capacity : Dictionary

var _contents_dictionary : Dictionary

signal item_removed(item:Item)
signal item_added(item:Item)
signal contents_changed

#func use_item(item:Item, user:Character):
	#if remove_items(item) == 1:
		#item.use(user)

func add_items(item:Item, quantity:int=1)->int:
	var max_capacity : int = max_item_capacity[item] if max_item_capacity.has(item) else 0
	var current_count : int = _contents_dictionary[item] if _contents_dictionary.has(item) else 0
	var quantity_capacity :int = min(quantity,max_capacity - current_count)
	quantity_capacity = max(0,quantity_capacity)
	if quantity_capacity > 0:
		if _contents_dictionary.has(item):
			_contents_dictionary[item] += quantity_capacity
		else:
			_contents_dictionary[item] = quantity_capacity
	
		item_added.emit(item)
		contents_changed.emit()
	return quantity_capacity

func get_items_count()->int:
	return _contents_dictionary.keys().size()

func get_items()->Array[Item]:
	var items : Array[Item]
	for item in _contents_dictionary.keys():
		items.append(item)
	items.sort()
	return items

func get_item_quantity(item:Item)->int:
	return _contents_dictionary.get(item,0)

func get_item_max_capacity(item:Item)->int:
	return max_item_capacity.get(item,0.0)

func get_item_capacity(item:Item)->int:
	return get_item_max_capacity(item) - get_item_quantity(item)

func remove_items(item:Item, quantity:int=1)->int:
	var removed_quantity := 0
	if _contents_dictionary.has(item):
		if _contents_dictionary[item] > quantity:
			_contents_dictionary[item] -= quantity
			removed_quantity = quantity
		else:
			removed_quantity = _contents_dictionary[item]
			_contents_dictionary.erase(item)
		item_removed.emit(item)
		contents_changed.emit()
	return removed_quantity
