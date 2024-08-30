class_name Interactor
extends RayCast3D

enum State {
	INTERACTIVE,
	ASSIGNED
}

@export_flags_3d_physics var interaction_mask : int
@export var character : Character
@export var ignore_areas : Array[InteractionArea]:
	set(value):
		clear_exceptions()
		for area in value:
			add_exception(area)

var interactions: Array[Interaction]:
	get:
		return _available_interactions

var state : State

signal interactions_changed(interactions:Array[Interaction])
signal selected_interaction_changed()

var _current_interaction_areas : Array[InteractionArea]
var _current_interaction_body : Node
var _all_interactions : Array[Interaction]
var _available_interactions : Array[Interaction]

var _current_selection_index : int:
	set(value):
		var new_value := value % _available_interactions.size() if _available_interactions.size() > 0 else 0
		if new_value != _current_selection_index:
			_current_selection_index = new_value
			selected_interaction_changed.emit()

# Called when the node enters the scene tree for the first time.
func _ready():
	state = State.INTERACTIVE

func cycle_selected_interaction():
	_current_selection_index += 1

func get_selected_interaction()->Interaction:
	return _available_interactions[_current_selection_index] if _available_interactions.size() > 0 else null

func interact():
	var selected_interaction := get_selected_interaction()
	if is_instance_valid(selected_interaction):
		selected_interaction.interact(character)

func add_interaction(interaction:Interaction):
	if not _all_interactions.has(interaction):
		_all_interactions.append(interaction)
		interactions_changed.emit(interactions)
		_update_available_interactions()

func remove_interaction(interaction:Interaction):
	if _all_interactions.has(interaction):
		_all_interactions.erase(interaction)
		interactions_changed.emit(interactions)
		_update_available_interactions()

func add_interactions(interactions:Array[Interaction]):
	for interaction in interactions:
		add_interaction(interaction)

func remove_interactions(interactions:Array[Interaction]):
	for interaction in interactions:
		remove_interaction(interaction)

func _add_interaction_area(area:InteractionArea):
	if _current_interaction_areas.has(area):
		return
	_current_interaction_areas.append(area)
	for interaction in area.interactions:
		add_interaction(interaction)
		
func _remove_interaction_area(area:InteractionArea):
	_current_interaction_areas.erase(area)
	for interaction in area.interactions:
		remove_interaction(interaction)

func _update_interaction_body(body:Node):
	if body == _current_interaction_body:
		return
	if is_instance_valid(_current_interaction_body):
		for child in _current_interaction_body.get_children():
			if child is Interaction:
				remove_interaction(child)
	_current_interaction_body = body
	var new_body_interactions :Array[Interaction]
	if is_instance_valid(_current_interaction_body):
		for child in _current_interaction_body.get_children():
			if child is Interaction:
				add_interaction(child)

func _update_available_interactions():
	var all_interactions : Array[Interaction]
	for interaction in _all_interactions:
		if is_instance_valid(interaction):
			all_interactions.append(interaction)
		else:
			_all_interactions.erase(interaction)
	_available_interactions = all_interactions
	_current_selection_index = min(_current_selection_index, _available_interactions.size())
	interactions_changed.emit(_available_interactions)

func update_interactions():
	var new_interaction_body : Node
	if state == State.INTERACTIVE:
		if is_colliding():
			var collider = get_collider()
			if is_instance_valid(collider):
				new_interaction_body = collider
	_update_interaction_body(new_interaction_body)
	
	var new_interaction_areas : Array[InteractionArea]
	if state == State.INTERACTIVE:
		var query := PhysicsPointQueryParameters3D.new()
		query.position = global_position
		query.collision_mask = interaction_mask
		query.collide_with_areas = true
		query.collide_with_bodies = false
		var results := get_world_3d().direct_space_state.intersect_point(query)
		
		for result in results:
			var collider = result['collider']
			if collider is InteractionArea:
				new_interaction_areas.append(collider)
	for area in _current_interaction_areas:
		if not new_interaction_areas.has(area):
			_remove_interaction_area(area)
	for area in new_interaction_areas:
		if not _current_interaction_areas.has(area):
			_add_interaction_area(area)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update_interactions()
