class_name InteractionsDisplay
extends VBoxContainer

const INTERACTION_PANEL_SCENE := preload("res://interaction_panel_container.tscn")

var interactor : Interactor:
	set(value):
		interactor = value
		interactor.interactions_changed.connect(on_interactions_changed)
		interactor.selected_interaction_changed.connect(on_selected_interaction_changed)

func on_selected_interaction_changed():
	var selected_interaction :Interaction= interactor.get_selected_interaction()
	for child in get_children():
		if child.interaction == selected_interaction:
			child.selected = true
		else:
			child.selected = false

func on_interactions_changed(interactions:Array[Interaction]):
	for child in get_children():
		child.visible = false
		child.queue_free()
	for interaction in interactions:
		var interaction_panel :InteractionPanelContainer = INTERACTION_PANEL_SCENE.instantiate()
		add_child(interaction_panel)
		interaction_panel.interaction = interaction
	on_selected_interaction_changed()
