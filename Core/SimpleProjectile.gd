class_name SimpleProjectile
extends CharacterBody3D

signal landed

var angular_velocity : float

var on_floor : bool

var responsible_node : Node

func set_responsible_node(node:Node):
	responsible_node = node

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		on_floor = false
		velocity += get_gravity() * delta
	rotation.y += angular_velocity * delta
	move_and_slide()
	if not on_floor and is_on_floor():
		on_floor = true
		landed.emit()
	if on_floor:
		var lateral_velocity := velocity * Vector3(1,0,1)
		velocity -= lateral_velocity.normalized() * lateral_velocity.length() * 0.1
		angular_velocity -= abs(angular_velocity) * 0.1
