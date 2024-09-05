class_name NodeMaterial
extends Resource

@export var text : StringName
@export var traction : float = 1.0
@export var base_color : Color
@export var accent_color : Color


static func get_collision_shape_material(collider:CollisionObject3D, shape_id:int)->NodeMaterial:
	var owner_id = collider.shape_find_owner(shape_id) # The owner ID in the collider.
	var shape = collider.shape_owner_get_owner(owner_id)
	for child in shape.get_children():
		if child is MaterialNode:
			return child.material
	return null
