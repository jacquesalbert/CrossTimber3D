class_name ToolPickup
extends Pickup

@export var tool:Tool
@export var interaction_area : InteractionArea
@export var interaction:Interaction
@export var streamplayer : AudioStreamPlayer3D

func _ready():
	super._ready()
	init_from_tool(tool)
	streamplayer.stream = tool.drop_sound
	streamplayer.play()
	

func init_from_tool(tool:Tool):
	if not tool:
		queue_free()
		return
	var graphics := tool.pickup_graphics.instantiate()
	add_child(graphics)
	interaction.tool = tool
	interaction.icon = tool.icon
	interaction.picked_up.connect(on_picked_up)
	#streamplayer.stream = tool.pickup_sound

func on_picked_up():
	interaction_area.active = false
	streamplayer.stream = tool.pickup_sound
	streamplayer.play()
	streamplayer.reparent(get_tree().root)
	streamplayer.finished.connect(streamplayer.queue_free)
	queue_free()
	
