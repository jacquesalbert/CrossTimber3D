class_name SurfaceCast3D
extends RayCast3D

var _current_surface : NodeMaterial:
	set(value):
		if _current_surface != value:
			_current_surface = value
			surface_changed.emit(_current_surface)

signal surface_changed(surface:NodeMaterial)

func _physics_process(delta: float) -> void:
	var cast_material : NodeMaterial
	if is_colliding():
		cast_material = NodeMaterial.get_collision_shape_material(get_collider(),get_collider_shape())
	_current_surface = cast_material
