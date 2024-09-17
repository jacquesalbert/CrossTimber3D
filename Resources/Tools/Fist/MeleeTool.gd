extends ToolInstance

@export var firer : BulletFirer

func set_character(character:Character):
	super.set_character(character)
	firer.responsible_node = character
	if is_instance_valid(character):
		firer.add_exception(character.hitbox)
		

func on_equip():
	super.on_equip()

func on_unequip():
	super.on_unequip()

func attack():
	if not ready_to_fire:
		return
	firer.fire()
	streamplayer.play()
	fired.emit()
	set_not_ready_to_fire()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if triggered:
		attack()
