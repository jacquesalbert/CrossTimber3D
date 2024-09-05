class_name InteractionArea
extends Area3D

var interactions : Array[Interaction]:
	get:
		var interactions : Array[Interaction]
		if not active:
			return interactions
		for child in get_children():
			if child is Interaction:
				interactions.append(child)
		return interactions

var active : bool = true
