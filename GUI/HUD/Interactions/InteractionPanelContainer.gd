class_name InteractionPanelContainer
extends PanelContainer

@export var selected_stylebox : StyleBoxFlat
@export var icon_rect : TextureRect
@export var label : Label

var interaction : Interaction:
	set(value):
		interaction = value
		icon_rect.texture = interaction.icon
		label.text = interaction.text
var selected : bool:
	set(value):
		selected = value
		if selected:
			add_theme_stylebox_override("panel", selected_stylebox)
			$GridContainer/MarginContainer/TextureRect.modulate = Color.BLACK
			$GridContainer/MarginContainer2/Label.add_theme_color_override("font_color",Color.BLACK)
		else:
			$GridContainer/MarginContainer/TextureRect.modulate = Color.WHITE
			$GridContainer/MarginContainer2/Label.remove_theme_color_override("font_color")
			remove_theme_stylebox_override("panel")
