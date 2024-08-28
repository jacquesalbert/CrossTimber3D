class_name VehicleControlMount
extends Mount

func mount(character:Character):
	super.mount(character)
	vehicle.driver_character = character

func dismount(character:Character):
	super.dismount(character)
	vehicle.driver_character = null
