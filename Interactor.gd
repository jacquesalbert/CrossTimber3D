class_name Interactor
extends RayCast3D

enum State {
	INTERACTIVE,
	ASSIGNED
}

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

var _current_interaction_area : InteractionArea:
	set(value):
		_current_interaction_area = value
		var new_area_interactions :Array[Interaction]
		if is_instance_valid(_current_interaction_area) and _current_interaction_area.active:
			new_area_interactions.append_array(_current_interaction_area.interactions)
		_area_interactions = new_area_interactions
			
var _assigned_interactions : Array[Interaction]:
	set(value):
		_assigned_interactions = value
		var all_interactions : Array[Interaction]
		all_interactions.append_array(_assigned_interactions)
		if state == State.INTERACTIVE:
			all_interactions.append_array(_area_interactions)
		_available_interactions = all_interactions

var _current_selection_index : int:
	set(value):
		var new_value := value % _available_interactions.size() if _available_interactions.size() > 0 else 0
		if new_value != _current_selection_index:
			_current_selection_index = new_value
			selected_interaction_changed.emit()

var _area_interactions : Array[Interaction]:
	set(value):
		_area_interactions = value
		
		var all_interactions : Array[Interaction]
		all_interactions.append_array(_assigned_interactions)
		if state == State.INTERACTIVE:
			all_interactions.append_array(_area_interactions)
		_available_interactions = all_interactions

var _available_interactions : Array[Interaction]:
	set(value):
		_available_interactions = value
		_current_selection_index = min(_current_selection_index, _available_interactions.size())
		interactions_changed.emit(_available_interactions)

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
	if not _assigned_interactions.has(interaction):
		_assigned_interactions.append(interaction)
		interactions_changed.emit(interactions)

func add_interactions(interactions:Array[Interaction]):
	for interaction in interactions:
		add_interaction(interaction)

func remove_interaction(interaction:Interaction):
	if _assigned_interactions.has(interaction):
		_assigned_interactions.erase(interaction)
		interactions_changed.emit(interactions)

func remove_interactions(interactions:Array[Interaction]):
	for interaction in interactions:
		remove_interaction(interaction)

#func get_available_interactions()->Array[Interaction]:
	#var all_interactions : Array[Interaction]
	#if state == State.INTERACTIVE:
		#if _current_interaction_area:
			#all_interactions.append_array(_current_interaction_area.interactions)
	#all_interactions.append_array(_assigned_interactions)
	#return all_interactions

func update_interactions():
	var new_interaction_area : InteractionArea = null
	if is_colliding():
		var collider = get_collider()
		if is_instance_valid(collider) and collider is InteractionArea and collider.active:
			new_interaction_area = collider
	_current_interaction_area = new_interaction_area

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if state == State.INTERACTIVE:
		update_interactions()
