class_name SlotToolUser
extends ToolUser

@export var default_tool : Tool

@export var tool_slots : int:
	set(value):
		tool_slots = value
		_tool_slots.resize(tool_slots)

@export var current_tool_slot : int:
	set(value):
		current_tool_slot = value % tool_slots
		set_tool_slot(current_tool_slot)

var _tool_slots : Array[Tool]

signal current_slot_changed(slot:int,tool:Tool)
signal slot_changed(slot:int,tool:Tool)

func _ready():
	super._ready()
	if default_tool:
		for slot in range(tool_slots):
			set_slot_tool(slot,default_tool)

func clear_slot(slot:int):
	set_slot_tool(slot, null)
	
func set_slot_tool(slot:int,tool:Tool):
	_tool_slots[slot] = tool
	if slot == current_tool_slot:
		equip_tool(_tool_slots[current_tool_slot])
	slot_changed.emit(slot,_tool_slots[slot])
	
func set_current_slot_tool(tool:Tool=null):
	set_slot_tool(current_tool_slot, tool)

func advance_to_next_filled_slot():
	var next_tool_slot :int = (current_tool_slot + 1) % tool_slots
	var i :int = 0
	while i < tool_slots and (_tool_slots[next_tool_slot] == null or _tool_slots[next_tool_slot] == default_tool):
		next_tool_slot = (next_tool_slot + 1) % tool_slots
		i += 1
	current_tool_slot = next_tool_slot

func next_unfilled_slot()->int:
	var next_tool_slot :int = current_tool_slot
	var i :int = 0
	while i < tool_slots and not (_tool_slots[next_tool_slot] == null or _tool_slots[next_tool_slot] == default_tool):
		next_tool_slot = (next_tool_slot + 1) % tool_slots
		i += 1
	if i == tool_slots:
		return -1
	return next_tool_slot
	
func consume_current_tool():
	set_current_slot_tool()
	advance_to_next_filled_slot()

func set_tool_slot(slot:int):
	equip_tool(_tool_slots[current_tool_slot])
	current_slot_changed.emit(current_tool_slot,_tool_slots[current_tool_slot])

func cycle_tool():
	current_tool_slot += 1
