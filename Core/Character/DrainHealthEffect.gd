extends Effect

@export var damage : int

var responsible_node : Node

signal drained(amount:int)

func _enter_tree():
	super._enter_tree()
	var parent := get_parent()
	_interval_timer.timeout.connect(drain_health)

func drain_health():
	var parent := get_parent()
	if parent is Character:
		if parent.health.value > 0:
			parent.health.modify(-damage,responsible_node)
			drained.emit(damage)
