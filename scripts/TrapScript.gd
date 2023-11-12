extends CharacterBody2D

# big list of values used to determine the logic for the trap
@export var launchVelocity = Vector2.ZERO
@export var pixelsPerSecond = 50
@export var collide = false
@export var bounce = false
@export var active = false
@export var stopTime = 0.0
@export var reactivatable = false
@export var playSound = true
@export var setVisiblity = true
@export var startVisible = true
var locked = false

# sync another node's movement to self
@export var nodeToSync:NodePath
@onready var getSync = get_node_or_null(nodeToSync)

func _ready():
	# set visible to what start visible is set to
	visible = startVisible
	velocity = launchVelocity*pixelsPerSecond
	# check that getSync isn't a child
	if getSync != null:
		if has_node(nodeToSync):
			getSync.call_deferred("reparent",get_parent(),true)

func _physics_process(delta):
	# only run logic if active
	if (active && !locked):
		# if the object is collidable then stop movement when colliding
		if (collide):
			var move = velocity
			set_up_direction(Vector2.DOWN)
			move_and_slide()
			
			# if bounce then bounce the velocity in the other direction (do an exception for the player)
			var collisions = get_slide_collision_count()
			if (collisions > 0):
				if bounce:
					for i in collisions:
						# avoid having the object stick
						if velocity.normalized() != get_slide_collision(i).get_normal():
							velocity = move.bounce(get_slide_collision(i).get_normal())
				else:
					velocity = move
		# move
		else:
			position += velocity*delta
		
		# sync other node (if exists)
		if getSync != null:
			getSync.global_position = global_position+velocity.normalized()
		
		# if stop time is above 0 the run stop active logic
		if stopTime > 0:
			# check that the next frame won't go into the negatives
			if stopTime - delta <= 0:
				# if it does then stop active
				active = false
				# if not reactivatable then lock the object
				if !reactivatable:
					locked = true
			# count the timer down
			stopTime -= delta


func _on_Trigger_body_entered(_body):
	# check that the trigger is not active or is reactivatable
	if !active || reactivatable:
		# set visibility based on what set visibiliy is
		visible = setVisiblity
		# if play sound is active then play the sound in the "LaunchSound" node
		if playSound:
			$LaunchSound.play()
		# set active
		active = true
