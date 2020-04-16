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
	var positionOverwrite = Vector2.ZERO;
	# only run logic if active
	if (active && !locked):
		# if the object is collidable then stop movement when colliding
		if (collide):
			# godot doesn't like physics sync on move and collide so we disable it temporarily
			set_sync_to_physics(false);
			var move = move_and_slide(velocity*pixelsPerSecond, Vector2.DOWN, true, 1);
			# re enable physics sync
			set_sync_to_physics(true);
			# move back from slides
			position -= move*delta;
			# if bounce then bounce the velocity in the other direction (do an exception for the player)
			var collisions = get_slide_count();
			if (collisions > 0):
				# overwrite position
				#positionOverwrite = position + move;
				#set end position
				position += move*delta;
				if bounce:
					for i in collisions:
						#positionOverwrite = move
						# avoid having the object stick
						if velocity.normalized() != get_slide_collision(i).normal:
							velocity = velocity.bounce(get_slide_collision(i).normal);
				else:
					velocity = move;
			#else:
			# if no bounce then set velocity to move
			#	velocity = move;
		# move
		#if (positionOverwrite != Vector2.ZERO):
		#	position = positionOverwrite;
		#else:
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
