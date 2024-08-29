class_name StatPanel
extends PanelContainer

@export var value_bar : ProgressBar
@export var trauma_bar : ProgressBar
@export var label : Label
@export var timer : Timer


var stat : Stat:
	set(value):
		if is_instance_valid(stat):
			stat.changed.disconnect(update_stat)
		stat = value
		stat.changed.connect(update_stat)
		value_bar.max_value = stat.max_value
		trauma_bar.max_value = stat.max_value
		timer.timeout.connect(set_damage_bar)
		update_stat(stat.value,null)
		set_damage_bar()

func update_stat(new_value:int,changed_by:Node):
	value_bar.value = stat.value
	label.text = str(stat.value)
	timer.start(0)

func set_damage_bar():
	trauma_bar.value = stat.value
