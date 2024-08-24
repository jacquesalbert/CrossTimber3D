class_name Pickup
extends CharacterBody3D

const ELEVATION : float = 75
const INITIAL_VELOCITY : float = 10

func _ready() -> void:
	velocity = INITIAL_VELOCITY * Vector3.FORWARD.rotated(Vector3.RIGHT,ELEVATION).rotated(Vector3.UP,randf()*TAU)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
