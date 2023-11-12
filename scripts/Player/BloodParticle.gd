extends Node2D
@onready var velocity = Vector2(randf_range(-1,1),randf_range(1,-1)).normalized()*randf_range(100,400)
const GRAVITY = 600
const MAX_GRAV = 600

func _physics_process(delta):
	# just move the node, we're avoiding physics outside of a single raycast to save on processing
	position += velocity*delta
	#set cast to next position
	$CollisionCheck.set_target_position(velocity*delta*2)
	
	# if the 2D ray cast hits something...
	if $CollisionCheck.is_colliding():
		if !($CollisionCheck.get_collider().is_in_group("IgnoreBlood")):
			#if ($CollisionCheck.get_collider().get_collision_mask_bit(0) == $CollisionCheck.get_collision_mask_bit(0)):
			global_position = $CollisionCheck.get_collision_point()
			# randomize position by a bit to add variation to the blood pattern
			position += Vector2(randf_range(-2,2),randf_range(-2,2))
			# stop collission (this will stop running this function all together, figured it would save on processing)
			set_physics_process(false)
			# reparent to keep blood on moving objects
			reparent($CollisionCheck.get_collider(),true)
	# rotate the sprite in the direction we're moving (helps gives variation to the shape)
	#look_at(position+velocity)
	# apply gravity
	if velocity.y < MAX_GRAV:
		velocity.y += GRAVITY*delta
