class_name ToolPickup
extends Pickup

@export var tool:Tool
@export var interaction_area : InteractionArea
@export var interaction:Interaction
@export var pickup_stream : AudioStreamPlayer3D

func _ready():
	super._ready()
	init_from_tool(tool)

func init_from_tool(tool:Tool):
	if not tool:
		queue_free()
		return
	var graphics := tool.pickup_graphics.instantiate()
	add_child(graphics)
	interaction.tool = tool
	interaction.icon = tool.icon
	interaction.picked_up.connect(on_picked_up)
	pickup_stream.stream = tool.pickup_sound

func on_picked_up():
	interaction_area.active = false
	pickup_stream.play()
	pickup_stream.reparent(get_tree().root)
	pickup_stream.finished.connect(pickup_stream.queue_free)
	queue_free()
	
