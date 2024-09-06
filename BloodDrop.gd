class_name BloodDrop
extends SimpleProjectile

@export var splat : Texture2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	velocity += get_gravity() * delta
	position += velocity * delta
	#move_and_slide()
	#var collision := move_and_collide(velocity * delta)
	#if collision:
	if position.y < 0:
		LevelManager.current_level.blood_map.set_point(position,Color(0.7,0.0,0.0,1.0))
		queue_free()
	#for i in range(get_slide_collision_count()):
		#var collision := get_slide_collision(i)
		#var collision_point := collision.get_position()
		#var normal := collision.get_normal()
		#LevelManager.current_level.blood_map.set_point(collision_point,Color(0.7,0.0,0.0,1.0))
		#var decal := Sprite3D.new()
		#decal.position = collision_point
		#decal.basis = Basis.looking_at(normal,Vector3.FORWARD.rotated(Vector3.UP,randf()*TAU))
		#decal.pixel_size = 0.05
		#decal.modulate = Color.RED
		#decal.texture = splat
		#decal.axis = 2
		#decal.shaded = true
		#decal.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		#decal.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		##decal.axis = Sprite3D.axis
		#LevelManager.spawn_in_level(decal)
		#queue_free()
