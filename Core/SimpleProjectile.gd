class_name SimpleProjectile
extends CharacterBody3D

signal landed

var angular_velocity : float

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	rotation.y += angular_velocity * delta
	move_and_slide()
	if is_on_floor():
		landed.emit()
		var lateral_velocity := velocity * Vector3(1,0,1)
		velocity -= lateral_velocity.normalized() * lateral_velocity.length() * 0.1
		angular_velocity -= abs(angular_velocity) * 0.1
