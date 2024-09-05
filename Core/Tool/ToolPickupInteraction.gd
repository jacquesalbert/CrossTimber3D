extends Interaction

@export var tool : Tool

signal picked_up

func interact(character:Character):
	var tool_user := character.tool_user if tool.category == Tool.Category.WEAPON else character.equipment_user
	
	var next_slot :int= tool_user.next_unfilled_slot()
	if next_slot == -1:
		var current_tool :Tool= tool_user.current_tool
		if current_tool:
			var new_pickup :Node3D = current_tool.get_pickup()
			if new_pickup:
				new_pickup.global_position = character.global_position
				#new_pickup.target = character.global_position + character.global_transform.x * 16
				#new_pickup.angular_speed = 2
				new_pickup.rotation.y = randf()*TAU
				LevelManager.spawn_in_level(new_pickup)
		tool_user.set_current_slot_tool(tool)
	else:
		tool_user.set_slot_tool(next_slot,tool)
		tool_user.current_tool_slot = next_slot
	picked_up.emit()
