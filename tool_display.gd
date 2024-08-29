class_name ToolDisplay
extends VBoxContainer

const TOOL_PANEL_SCENE := preload("res://tool_panel.tscn")
var tool_user:SlotToolUser:
	set(value):
		tool_user = value
		for i in range(tool_user.tool_slots):
			var panel := TOOL_PANEL_SCENE.instantiate()
			add_child(panel)
			panel.slot = i
			panel.tool_user = tool_user

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
