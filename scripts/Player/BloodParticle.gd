extends Node2D
onready var velocity = Vector2(rand_range(-1,1),rand_range(1,-1)).normalized()*rand_range(100,400);
const GRAVITY = 600;
const MAX_GRAV = 600;

func _physics_process(delta):
	# if the 2D ray cast hits something...
	if $CollisionCheck.is_colliding():
		# stop collission (this will stop running this function all together, figured it would save on processing)
		set_physics_process(false);
	# rotate the sprite in the direction we're moving (helps gives variation to the shape)
	look_at(position+velocity);
	# apply gravity
	if velocity.y < MAX_GRAV:
		velocity.y += GRAVITY*delta;
	# just move the node, we're avoiding physics outside of a single raycast to save on processing
	position += velocity*delta;
