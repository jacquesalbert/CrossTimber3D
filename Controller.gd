class_name Controller
extends Node3D

var character : Character

var movement : Vector2:
	set(value):
		movement = value.limit_length(1.0)

var run : bool

var aim_point : Vector3:
	set(value):
		aim_point = value

var global_aim_point : Vector3:
	set(value):
		aim_point = value - global_position
	get:
		return global_position + aim_point

var look_angle : float:
	set(value):
		aim_point = Vector3.MODEL_FRONT.rotated(Vector3.UP,value) * aim_distance
	get:
		return Vector3.MODEL_FRONT.signed_angle_to(aim_point,Vector3.UP)

var aim_distance : float:
	set(value):
		aim_point = Vector3.MODEL_FRONT.rotated(Vector3.UP,look_angle) * value
	get:
		return aim_point.length()

var steer : float:
	set(value):
		steer = clamp(value, -1.0,1.0)

var brake : float:
	set(value):
		brake = clamp(value,0.0,1.0)

var throttle : float:
	set(value):
		throttle = clamp(value,-1.0,1.0)

var traction_control : bool = true

signal trigger_tool_on
signal trigger_tool_off
signal trigger_equipment_on
signal trigger_equipment_off
signal cycle_tool
signal cycle_equipment
signal interact
signal cycle_interaction

#var attack : bool
#var interact : bool
#var use_equipment : bool
#var cycle_tool : bool
#var cycle_equipment : bool
