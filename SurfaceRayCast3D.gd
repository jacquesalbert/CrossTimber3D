class_name SurfaceRayCast3D
extends RayCast3D

var surface : Node3D:
	set(value):
		if surface != value:
			surface = value
			surface_changed.emit(surface)

signal surface_changed(new_surface:Node3D)

func _physics_process(delta: float) -> void:
	if is_colliding():
		var collider := get_collider()
		if collider.has_method("get_effect_material"):
			surface = collider
			return
		surface = null
	surface = null
