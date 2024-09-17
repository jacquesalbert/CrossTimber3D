extends ToolInstance

@export var firer : BulletFirer
@export var animation_player : AnimationPlayer
@export var supply : Item
@export var supply_amount : int

@export var fire_stream : AudioStream
@export var empty_stream : AudioStream


func set_character(character:Character):
	super.set_character(character)
	firer.responsible_node = character
	if is_instance_valid(character):
		firer.exceptions.append(character.hitbox)

func on_equip():
	super.on_equip()

func on_unequip():
	super.on_unequip()

func attack():
	if not ready_to_fire:
		return
	
	var fire := true
	var inventory:Inventory
	
	if supply:
		if is_instance_valid(self.character) and is_instance_valid(self.character.inventory):
			inventory = self.character.inventory
			if inventory.get_item_quantity(supply) < supply_amount:
				fire = false
		else:
			fire = false

	if fire:
		if supply:
			inventory.remove_items(supply,supply_amount)
		firer.fire()
		animation_player.play("fire")
		streamplayer.stream = fire_stream
		streamplayer.play()
		fired.emit()
		#$CameraShaker.add_trauma()
	else:
		streamplayer.stream = empty_stream
		streamplayer.play()
		failed.emit()
	set_not_ready_to_fire()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if triggered:
		attack()
