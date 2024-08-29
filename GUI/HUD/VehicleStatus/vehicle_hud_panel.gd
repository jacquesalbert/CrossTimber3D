class_name VehicleHUDPanel
extends PanelContainer

const MS_TO_MPH : float = 2.23694

@export var health_stat_display : StatPanel
@export var fuel_stat_display : StatPanel
@export var speed_label : Label

var vehicle:Vehicle:
	set(value):
		vehicle = value
		on_vehicle_changed(vehicle)


func on_vehicle_changed(vehicle:Vehicle):
	if is_instance_valid(vehicle):
		show()
		health_stat_display.stat = vehicle.health
		fuel_stat_display.stat = vehicle.fuel
	else:
		hide()

func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(vehicle):
		speed_label.text = str(round(vehicle.get_speedo() * MS_TO_MPH))
