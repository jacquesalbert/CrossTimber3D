class_name Character
extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_flags_2d_physics var character_body_layer
@export var exhaustion_effect_scene : PackedScene

var controller : Controller
@onready var tool_user : SlotToolUser = $ToolUser
@onready var equipment_user : SlotToolUser = $EquipmentUser
@onready var graphics : CharacterGraphics = $CharacterGraphics
@onready var health : Stat = $Health
@onready var energy : Stat = $Energy
@onready var interactor : Interactor = $Interactor
@onready var inventory : Inventory = $Inventory
@onready var supply_area : SupplyArea = $SupplyArea
#@onready var bleeder : Decaler = $BloodDecaler
#@onready var small_bleeder : Decaler = $SmallBloodDecaler
@onready var hitbox : Hitbox = $Hitbox
@onready var attributes : EntityAttributeHandler = $EntityAttributeHandler
#@onready var cover_detector : CoverDetector = $CoverDetector
@onready var tracker : Tracker = $Tracker
@onready var ray_cast : RayCast3D = $RayCast3D

enum State {
	ACTIVE,
	DRIVER_MOUNTED,
	MOUNTED,
	INACTIVE
}

var state : State
var request_state : State

var running : bool
var current_mount:Mount
var _current_effects: Array[Effect]
var _current_traits: Array[Trait]
var _run_energy_debt : float
var _exhausted_effect : Effect
var _traction : float
var _current_surface : Node3D:
	set(value):
		if _current_surface != value:
			_current_surface = value
			var effect_material :StringName= "none"
			if is_instance_valid(_current_surface) and _current_surface.has_method("get_effect_material"):
				effect_material = _current_surface.get_effect_material()
			tracker.change_effect_material(effect_material)
			surface_changed.emit(_current_surface)
			_traction = _current_surface.get_traction() if is_instance_valid(_current_surface) and _current_surface.has_method("get_traction") else 0.0

signal effects_changed
signal traits_changed
signal surface_changed(surface:Node3D)
signal mount_changed(mount:Mount)

func apply_controls(delta:float, aim_only:bool=false):
	var target_velocity_2d := Vector2.ZERO
	
	var turn_speed :float = attributes.get_attribute_value("turn_speed")
	var speed :float = attributes.get_attribute_value("speed")
	var run_modifier :float = attributes.get_attribute_value("run_modifier")
	var can_run :bool = attributes.get_attribute_value("can_run")
	var acceleration :float = attributes.get_attribute_value("acceleration")
	if controller:
		var aim_vector_flattened := controller.aim_point * Vector3(1,0,1)
		var look_at_rotation_y := -aim_vector_flattened.signed_angle_to(Vector3.MODEL_FRONT,Vector3.UP)
		global_rotation.y = rotate_toward(global_rotation.y,look_at_rotation_y,turn_speed*delta)
		var move_speed :float = speed * run_modifier if (running and can_run) else speed
		#var max_speed := speed if running and energized else speed * walk_modifier
		running = controller.run
		target_velocity_2d = controller.movement.rotated(-global_rotation.y) * move_speed

	if aim_only:
		return
	var target_velocity_3d := Vector3(target_velocity_2d.x, 0, target_velocity_2d.y)
	velocity = velocity.move_toward(target_velocity_3d,acceleration*_traction*delta)

func on_controls_trigger_tool_on():
	tool_user.trigger()

func on_controls_trigger_tool_off():
	tool_user.untrigger()

func on_controls_trigger_equipment_on():
	equipment_user.trigger()

func on_controls_trigger_equipment_off():
	equipment_user.untrigger()

func on_controls_cycle_tool():
	tool_user.cycle_tool()

func on_controls_cycle_equipment():
	equipment_user.cycle_tool()

func on_controls_interact():
	interactor.interact()

func on_controls_cycle_interaction():
	interactor.cycle_selected_interaction()

func _ready():
	child_entered_tree.connect(on_child_entered)
	child_exiting_tree.connect(on_child_exited)
	# first connect all the necessary components
	if attributes:
		attributes.attributes_changed.connect(update_attribute_values)
	#if cover_detector:
		#cover_detector.character = self
		#cover_detector.add_ignore_area(hitbox)
	if interactor:
		interactor.character = self
	if health:
		health.changed.connect(on_health_damaged)
		health.expended.connect(on_health_died)
	if tool_user:
		tool_user.character = self
		tool_user.tool_changed.connect(on_tool_changed)
		tool_user.tool_fired.connect(on_tool_activated)
		#if graphics:
			#graphics.tool = get_graphics_tool_type_from_tool_type(tool_user.current_tool.type)
	if equipment_user:
		equipment_user.character = self
		equipment_user.tool_changed.connect(on_equipment_changed)
		equipment_user.tool_fired.connect(on_equipment_activated)
	
	 #then load the settings
	load_character()
	
	# then connect the controller
	for child in get_children():
		if child is Controller:
			controller = child
			controller.character = self
	if controller:
		controller.cycle_tool.connect(on_controls_cycle_tool)
		controller.cycle_equipment.connect(on_controls_cycle_equipment)
		controller.trigger_tool_on.connect(on_controls_trigger_tool_on)
		controller.trigger_tool_off.connect(on_controls_trigger_tool_off)
		controller.trigger_equipment_on.connect(on_controls_trigger_equipment_on)
		controller.trigger_equipment_off.connect(on_controls_trigger_equipment_off)
		controller.interact.connect(on_controls_interact)
		controller.cycle_interaction.connect(on_controls_cycle_interaction)
	
	 #then update all components with attribute values
	update_attribute_values()
	
	 #finally, initialize the character as active
	set_active()


func update_attribute_values():
	var accuracy :float= attributes.get_attribute_value("accuracy")
	var max_health :int= attributes.get_attribute_value("health")
	var max_energy :int= attributes.get_attribute_value("energy")
	var ammo_capacity :float= attributes.get_attribute_value("ammo_capacity")
	if tool_user:
		tool_user.angle_accuracy = accuracy * 360.0
		#tool_user.distance_accuracy = attributes.accuracy
	if equipment_user:
		equipment_user.angle_accuracy = accuracy * 360.0
		#equipment_user.distance_accuracy = attributes.accuracy
	if health:
		health.max_value = max_health
	if energy:
		energy.max_value = max_energy
	if inventory:
		inventory.max_item_capacity[load("res://item_test.tres")] = ammo_capacity

func load_character():
	for child in get_children():
		if child is CharacterLoader:
			child.load_character(self)
			child.queue_free()

func _process(delta):
	run_energy(delta)
	if request_state != state:
		match request_state:
			State.ACTIVE:
				set_active()
			State.MOUNTED:
				set_mounted()
			State.DRIVER_MOUNTED:
				set_driver_mounted()
			State.INACTIVE:
				set_inactive()
		request_state = state
		
	match state:
		State.ACTIVE:
			active_process(delta)
		State.DRIVER_MOUNTED:
			pass
		State.MOUNTED:
			mount_process(delta)
		State.INACTIVE:
			pass

func _physics_process(delta):
	# enforce 2D play area
	position.y = 0
	if ray_cast.is_colliding():
		tracker.global_position = ray_cast.get_collision_point()
		tracker.normal_direction = ray_cast.get_collision_normal()
	_current_surface = ray_cast.get_collider()
	match state:
		State.ACTIVE:
			active_physics_process(delta)
		State.DRIVER_MOUNTED:
			pass
		State.MOUNTED:
			pass
		State.INACTIVE:
			pass

func on_health_died(killed_by:Node):
	request_state = State.INACTIVE
	drop_all_tools(tool_user)
	drop_all_tools(equipment_user)
	drop_all_supplies(inventory)
	if health.value <= -health.max_value * 0.5:
		print("gib")
		#graphics.gib()

func drop_all_supplies(supplies:Inventory):
	for item in supplies.get_items():
		var quantity := supplies.get_item_quantity(item)
		var pickups :Array[SupplyPickup] = item.get_pickups(quantity)
		for pickup in pickups:
			spawn_pickup(pickup)
		supplies.remove_items(item, quantity)

func drop_all_tools(user:SlotToolUser):
	for i in range(user.tool_slots):
		var tool := user._tool_slots[i]
		if tool:
			var pickup :ToolPickup = tool.get_pickup()
			if pickup:
				spawn_pickup(pickup)
		user.clear_slot(i)

func spawn_pickup(pickup:Pickup):
	LevelManager.spawn_in_level(pickup)
	pickup.global_position = global_position + Vector3.UP
	pickup.rotation = Vector3(0,randf(),0)*TAU

func on_health_damaged(amount:int, damaged_by:Node):
	pass
	#if graphics:
		#graphics.hurt(amount)
	#bleeder.queue_decals += max(0,-amount / 10)
	#small_bleeder.queue_decals += max(0,-amount % 10)

func on_tool_changed(from_tool:Tool, to_tool:Tool):
	if graphics:
		if to_tool:
			var graphics_tool := get_graphics_tool_type_from_tool_type(to_tool.type)
			graphics.tool = graphics_tool

func get_graphics_tool_type_from_tool_type(type:Tool.Type)->CharacterGraphics.ToolType:
	var graphics_tool : CharacterGraphics.ToolType
	match type:
		Tool.Type.UNARMED:
			graphics_tool = CharacterGraphics.ToolType.UNARMED
		Tool.Type.MELEE:
			graphics_tool = CharacterGraphics.ToolType.MELEE
		Tool.Type.SIDEARM:
			graphics_tool = CharacterGraphics.ToolType.SIDEARM
		Tool.Type.LONGARM:
			graphics_tool = CharacterGraphics.ToolType.LONGARM
		Tool.Type.THROWN:
			graphics_tool = CharacterGraphics.ToolType.THROWN
	return graphics_tool

func on_tool_activated():
	if graphics:
		graphics.activate_tool()

func on_equipment_changed(from_tool:Tool, to_tool:Tool):
	pass

func on_equipment_activated():
	pass

func set_inactive():
	#print_debug("Setting ", self, " inactive.")
	if state == State.DRIVER_MOUNTED or state == State.MOUNTED:
		current_mount.dismount(self)
	if controller is PlayerController:
		controller.mounted = false
	state = State.INACTIVE
	collision_layer = 0
	hitbox.disable()
	graphics.alive = false
	tool_user.triggered = false
	graphics.mounted = false
	graphics.driving = false
	supply_area.disable()
	tracker.disable()
	if controller:
		controller.trigger_tool_off.disconnect(on_controls_trigger_tool_off)
		controller.trigger_tool_on.disconnect(on_controls_trigger_tool_on)
		controller.trigger_equipment_off.disconnect(on_controls_trigger_equipment_off)
		controller.trigger_equipment_on.disconnect(on_controls_trigger_equipment_on)
		controller.interact.disconnect(on_controls_interact)
	
func set_active():
	var test_collision := move_and_collide(Vector3.ZERO,true)
	if test_collision:
		return false
	if controller is PlayerController:
		controller.mounted = false
	state = State.ACTIVE
	collision_layer = character_body_layer
	#z_index = 10
	hitbox.enable()
	supply_area.enable()
	#graphics.alive = true
	#graphics.mounted = false
	#graphics.driving = false
	#if controller:
		#if tool_user:
			#controller.trigger_tool_off.connect(on_controls_trigger_tool_off)
			#controller.trigger_tool_on.connect(on_controls_trigger_tool_on)
		#if equipment_user:
			#controller.trigger_equipment_off.connect(on_controls_trigger_equipment_off)
			#controller.trigger_equipment_on.connect(on_controls_trigger_equipment_on)
	tracker.enable()

func set_mounted():
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	#print_debug("Setting ", self, " active.")
	if controller is PlayerController:
		controller.mounted = true
	state = State.MOUNTED
	collision_layer = 0
	#z_index = -1
	hitbox.enable()
	supply_area.disable()
	#graphics.alive = true
	#graphics.mounted = true
	#graphics.driving = false
	##if tool_user:
		##on_tool_changed(null, tool_user.current_tool)
	tracker.disable()

func set_driver_mounted():
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	if controller is PlayerController:
		controller.mounted = true
	#print_debug("Setting ", self, " active.")
	state = State.DRIVER_MOUNTED
	collision_layer = 0
	#z_index = -1
	hitbox.enable()
	supply_area.disable()
	#graphics.alive = true
	#graphics.mounted = true
	#graphics.driving = true
	#if controller:
		#controller.trigger_tool_off.disconnect(on_controls_trigger_tool_off)
		#controller.trigger_tool_on.disconnect(on_controls_trigger_tool_on)
		#controller.trigger_equipment_off.disconnect(on_controls_trigger_equipment_off)
		#controller.trigger_equipment_on.disconnect(on_controls_trigger_equipment_on)
	tracker.disable()

func active_process(delta:float):
	apply_controls(delta)
	apply_graphics()

func apply_graphics():
	if not is_instance_valid(graphics):
		return
	if attributes.can_run:
		graphics.exhaustion = 0.0
	else:
		graphics.exhaustion = 1.0
	if controller:
		if attributes.can_run and running and controller.movement.length() > attributes.speed:
			graphics.move = "run"
		elif controller.movement.length() > 0.0:
			graphics.move = "walk"
		else:
			graphics.move = "idle"
		graphics.move_angle = controller.movement.angle()
	else:
		graphics.move = "idle"
		graphics.move_angle = 0

func active_physics_process(delta:float):
	# Add the gravity.
	#if not is_on_floor():
		#velocity.y -= gravity * delta
	move_and_slide()

func knockback_physics_process(delta:float):
	move_and_collide(Vector3.ZERO)
	if health.value > 0:
		request_state = State.ACTIVE
	else:
		request_state = State.INACTIVE

func mount(mount:Mount):
	reparent(mount)
	interactor.add_interactions(mount.interactions)
	if mount.control:
		request_state = State.DRIVER_MOUNTED
	else:
		request_state = State.MOUNTED
	current_mount = mount
	mount_changed.emit(current_mount)

func dismount(mount:Mount):
	global_position = mount.dismount_point.global_position
	reparent(get_tree().root)
	interactor.remove_interactions(mount.interactions)
	request_state = State.ACTIVE
	current_mount = null
	mount_changed.emit(current_mount)
	
func mount_process(delta:float):
	apply_controls(delta)

func get_effect_material()->StringName:
	return "flesh"

func on_child_exited(node:Node):
	if node is Effect:
		remove_effect(node)
	elif node is Trait:
		remove_trait(node)

func on_child_entered(node:Node):
	if node is Effect:
		add_effect(node)
	elif node is Trait:
		add_trait(node)

func add_effect(effect:Effect):
	_current_effects.append(effect)
	effects_changed.emit()
	for modifier in effect.modifiers:
		attributes.add_modifier(modifier)

func remove_effect(effect:Effect):
	_current_effects.erase(effect)
	effects_changed.emit()
	for modifier in effect.modifiers:
		attributes.remove_modifier(modifier)

func get_current_effects()->Array[Effect]:
	return _current_effects

func add_trait(_trait:Trait):
	_current_traits.append(_trait)
	traits_changed.emit()
	for modifier in _trait.modifiers:
		attributes.add_modifier(modifier)

func remove_trait(_trait:Trait):
	_current_traits.erase(_trait)
	traits_changed.emit()
	for modifier in _trait.modifiers:
		attributes.remove_modifier(modifier)

func get_current_traits()->Array[Trait]:
	return _current_traits

func run_energy(delta:float):
	var run_energy_rate : float = attributes.get_attribute_value("run_energy_rate")
	if running and not velocity.is_zero_approx():
		_run_energy_debt += run_energy_rate * delta
		if _run_energy_debt > 1.0 and energy.value > 0:
			#print_debug("consuming " + str(1.0) + " energy for running")
			energy.modify(-1.0,self)
			_run_energy_debt -= 1.0
	var exhausted := energy.value <= 0
	if exhausted:
		if not is_instance_valid(_exhausted_effect):
			_exhausted_effect = exhaustion_effect_scene.instantiate()
			add_child(_exhausted_effect)
	else:
		if is_instance_valid(_exhausted_effect):
			remove_child(_exhausted_effect)
			_exhausted_effect.queue_free()
