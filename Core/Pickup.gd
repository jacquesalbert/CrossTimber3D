class_name Pickup
extends SimpleProjectile

const ELEVATION : float = 75
const INITIAL_VELOCITY : float = 10

func _ready() -> void:
	velocity = INITIAL_VELOCITY * Vector3.FORWARD.rotated(Vector3.RIGHT,ELEVATION).rotated(Vector3.UP,randf()*TAU)
