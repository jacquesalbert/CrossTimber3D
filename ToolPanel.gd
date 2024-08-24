class_name ToolPanel
extends PanelContainer

@export var selected_stylebox : StyleBoxFlat

var tool_user : SlotToolUser:
	set(value):
		if is_instance_valid(tool_user):
			tool_user.current_slot_changed.disconnect(on_current_slot_changed)
			tool_user.slot_changed.disconnect(on_slot_changed)
		tool_user = value
		tool_user.current_slot_changed.connect(on_current_slot_changed)
		tool_user.slot_changed.connect(on_slot_changed)
		on_slot_changed(slot,tool_user._tool_slots[slot])
		on_current_slot_changed(tool_user.current_tool_slot,tool_user.current_tool)
		
var slot : int

var tool:Tool:
	set(value):
		tool = value
		if tool:
			$GridContainer/MarginContainer/TextureRect.texture = tool.icon
			$GridContainer/MarginContainer2/Label.text = tool.text
		else:
			$GridContainer/MarginContainer/TextureRect.texture = null
			$GridContainer/MarginContainer2/Label.text = ""
var selected : bool:
	set(value):
		selected = value
		if selected:
			add_theme_stylebox_override("panel", selected_stylebox)
			$GridContainer/MarginContainer/TextureRect.modulate = Color.BLACK
			$GridContainer/MarginContainer2/Label.add_theme_color_override("font_color",Color.BLACK)
		else:
			$GridContainer/MarginContainer/TextureRect.modulate = Color.WHITE
			$GridContainer/MarginContainer2/Label.remove_theme_color_override("font_color")
			remove_theme_stylebox_override("panel")
		
func on_slot_changed(slot_id:int, tool:Tool):
	if slot_id == slot:
		self.tool = tool

func on_current_slot_changed(slot_id:int, tool:Tool):
	if slot_id == slot:
		selected = true
	else:
		selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
