class_name ToolUser
extends Node3D

@export var aim_noise: Noise
@export_range(0.0,360.0) var angle_accuracy :float= 5.0 # affects how far off the aim is in degrees
@export var frequency :float= 0.00016: # affects how fast the aim sways:
	set(value):
		frequency = value
		aim_noise.frequency = value
@export var elevation_noise : bool

@export var current_tool : Tool:
	set(new_tool):
		var previous_tool := current_tool
		if previous_tool != new_tool:
			current_tool = new_tool

var triggered : bool

var _noise_offset : Vector3
var _current_tool_instance : ToolInstance

var character:Character
#var cover_exceptions : Array[CollisionObject2D]

signal tool_changed(from_tool:Tool, to_tool:Tool)
signal tool_fired

# Called when the node enters the scene tree for the first time.
func _ready():
	if not aim_noise:
		aim_noise = FastNoiseLite.new()
		aim_noise.frequency = frequency
		aim_noise.seed = get_instance_id()
	_noise_offset = Vector3(randf()*1000, randf()*1000, randf()*1000)


#func add_cover(cover:CollisionObject2D):
	#cover_exceptions.append(cover)
	#if is_instance_valid(_current_tool_instance):
		#_current_tool_instance.cover_exceptions.append(cover)
#
#func remove_cover(cover:CollisionObject2D):
	#cover_exceptions.erase(cover)
	#if is_instance_valid(_current_tool_instance):
		#_current_tool_instance.cover_exceptions.erase(cover)

func equip_tool(tool:Tool=null):
	unequip_tool(_current_tool_instance)
	if current_tool != tool:
		tool_changed.emit(current_tool, tool)
		current_tool = tool
	if tool:
		var tool_scene := tool.instance
		if tool_scene:
			_current_tool_instance = tool_scene.instantiate()
			add_child(_current_tool_instance)
			register_instance(_current_tool_instance)
	else:
		_current_tool_instance = null

func unequip_tool(instance:ToolInstance):
	if is_instance_valid(instance):
		unregister_instance(instance)
		instance.queue_free()

func get_current_tool()->Tool:
	return current_tool

func get_current_tool_type()->Tool.Type:
	if is_instance_valid(current_tool):
		return current_tool.type
	return Tool.Type.UNARMED

func register_instance(instance:ToolInstance):
	#tool.attach_model(self)
	#instance.cover_exceptions = cover_exceptions.duplicate()
	instance.fired.connect(on_tool_fired)
	instance.set_character(character)
	instance.on_equip()

func unregister_instance(instance:ToolInstance):
	instance.untrigger()
	#instance.cover_exceptions = []
	#tool.detach_model()
	instance.fired.disconnect(on_tool_fired)
	instance.set_character(null)
	instance.on_unequip()

func on_tool_fired():
	_noise_offset += 1000 * Vector3.ONE * current_tool.recoil
	tool_fired.emit()
	if current_tool.consumable:
		consume_current_tool()

func consume_current_tool():
	equip_tool()

func trigger():
	if is_instance_valid(_current_tool_instance):
		_current_tool_instance.trigger()

func untrigger():
	if is_instance_valid(_current_tool_instance):
		_current_tool_instance.untrigger()

func update_aim_offset():
	var elevation_noise :float= frequency * (Time.get_ticks_msec() * Engine.time_scale + _noise_offset.x)
	var azimuth_noise :float = frequency * (Time.get_ticks_msec() * Engine.time_scale + _noise_offset.y)
	var elevation_adjustment : = aim_noise.get_noise_1d(elevation_noise) * deg_to_rad(angle_accuracy) * 0.5 if elevation_noise else 0.0
	rotation = Vector3(elevation_adjustment,aim_noise.get_noise_1d(azimuth_noise) * deg_to_rad(angle_accuracy) * 0.5,0)

func _process(delta):
	update_aim_offset()
