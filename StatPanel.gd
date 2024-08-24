class_name StatPanel
extends PanelContainer

var stat : Stat:
	set(value):
		if is_instance_valid(stat):
			stat.changed.disconnect(update_stat)
		stat = value
		stat.changed.connect(update_stat)
		$GridContainer/MarginContainer3/ProgressBar.max_value = stat.max_value
		$GridContainer/MarginContainer3/ProgressBar2.max_value = stat.max_value
		$GridContainer/MarginContainer3/Timer.timeout.connect(set_damage_bar)
		update_stat(stat.value,null)
		set_damage_bar()

func update_stat(new_value:int,changed_by:Node):
	$GridContainer/MarginContainer3/ProgressBar.value = stat.value
	$GridContainer/MarginContainer2/Label.text = str(stat.value)
	$GridContainer/MarginContainer3/Timer.start(0)

func set_damage_bar():
	$GridContainer/MarginContainer3/ProgressBar2.value = stat.value
