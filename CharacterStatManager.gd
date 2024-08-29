class_name CharacterStatManager
extends Node

@export var character : Character
@export var health_recharge_rate : float = 1.0 # how much healing per second
@export var health_exchange_rate : int = 1
@export var energy_exchange_rate : int = 2

@export var inventory_search_interval : float = 1.0

var _health_recharge_debt : float

var _inventory_search_timer : float

func search_inventory():
	var health_deficit := character.health.max_value - character.health.value
	if health_deficit > 0:
		for item in character.inventory.get_items():
			if item is HealthItem:
				var item_quantity_available := character.inventory.get_item_quantity(item)
				var stack_modify_amount : int= item.health*item.stack_size
				var use_quantity : int = 0
				if item_quantity_available >= item.stack_size and health_deficit >= stack_modify_amount:
					use_quantity = item.stack_size
				elif health_deficit >= item.health:
					use_quantity = 1
				if use_quantity > 0:
					character.inventory.remove_items(item,use_quantity)
					character.health.modify(item.health*use_quantity,character)
				return
	var energy_deficit := character.energy.max_value - character.energy.value
	if energy_deficit > 0:
		for item in character.inventory.get_items():
			if item is EnergyItem:
				var item_quantity_available := character.inventory.get_item_quantity(item)
				var stack_modify_amount : int= item.energy*item.stack_size
				var use_quantity : int = 0
				if item_quantity_available >= item.stack_size and energy_deficit >= stack_modify_amount:
					use_quantity = item.stack_size
				elif energy_deficit >= item.energy:
					use_quantity = 1
				if use_quantity > 0:
					character.inventory.remove_items(item,use_quantity)
					character.energy.modify(item.energy*use_quantity,character)
				return

func heal(timestep:float):
	var health_deficit := character.health.max_value - character.health.value
	if health_deficit > 0:
		_health_recharge_debt += health_recharge_rate * timestep
		_health_recharge_debt = min(health_deficit,_health_recharge_debt)
		if _health_recharge_debt >= health_exchange_rate:
			var heal_count : int = floor(_health_recharge_debt / health_exchange_rate)
			var heal_amount : int = health_exchange_rate * heal_count
			var energy_cost : float = (heal_amount * energy_exchange_rate) / health_exchange_rate
			if character.energy.value >= energy_cost:
				#print_debug("healing " + str(heal_amount) + " health for "+ str(energy_cost) + " energy")
				_health_recharge_debt -= heal_amount
				character.health.modify(heal_amount,character)
				character.energy.modify(-energy_cost,character)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float):
	if character.state != Character.State.ACTIVE:
		return
	
	_inventory_search_timer += delta
	if _inventory_search_timer >= inventory_search_interval:
		_inventory_search_timer -= inventory_search_interval
		search_inventory()
	
	heal(delta)
