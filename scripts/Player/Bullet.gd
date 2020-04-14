extends KinematicBody2D

# how many seconds should the bullet last?
var lifeTime = 0.96;

var velocity = Vector2.ZERO;

func _process(delta):
	# count down the life time, when below zero, delete
	if lifeTime > 0:
		lifeTime -= delta;
	else:
		queue_free();

func _physics_process(delta):
	# move, if collide hits something then delete self
	var collide = move_and_collide(velocity*delta);
	if collide:
		queue_free();
