extends KinematicBody2D

# big list of values used to determine the logic for the trap
export var velocity = Vector2.ZERO;
export var pixelsPerSecond = 50;
export var collide = false;
export var bounce = false;
export var active = false
export var stopTime = 0.0;
export var reactivatable = false;
export var playSound = true;
export var setVisiblity = true;
export var startVisible = true;
var locked = false;

func _ready():
	# set visible to what start visible is set to
	visible = startVisible;

func _physics_process(delta):
	# only run logic if active
	if (active && !locked):
		# if the object is collidable then stop movement when colliding
		if (collide):
			var check = move_and_collide(velocity*pixelsPerSecond*delta);
			# if bounce then bounce the velocity in the other direction (do an exception for the player)
			if check && bounce && check.collider != Global.player:
				velocity = velocity.bounce(check.normal);
		# otherwise always move
		else:
			position += velocity*pixelsPerSecond*delta;
		
		# if stop time is above 0 the run stop active logic
		if stopTime > 0:
			# check that the next frame won't go into the negatives
			if stopTime - delta <= 0:
				# if it does then stop active
				active = false;
				# if not reactivatable then lock the object
				if !reactivatable:
					locked = true;
			# count the timer down
			stopTime -= delta;


func _on_Trigger_body_entered(body):
	# check that the trigger is not active or is reactivatable
	if !active || reactivatable:
		# set visibility based on what set visibiliy is
		visible = setVisiblity;
		# if play sound is active then play the sound in the "LaunchSound" node
		if playSound:
			$LaunchSound.play();
		# set active
		active = true;
