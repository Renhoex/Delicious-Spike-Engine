extends CharacterBody2D

# physics variables
var ground = true # check for if the player is on the ground or not (allows more flexibility then is_on_floor() )
var gravityDirection = Vector2.DOWN # which diection the gravity pulls the player
var coyoteTime = 0 # how many seconds in the air can the player be before normal jumps are over (can be helpful if the player keeps rapidly changing between falling and landing)
# coyoteTime is a checker the time limit is in PlayerPhysics.gd
# multipliers for walking speed and gravity
var gravMultiplier = 1
var walkMultiplier = 1
var movement = Vector2.ZERO # local movement, this gets rotated for stuff like velocity

# gameplay variables
var airJump = 1 # Air jump counter
var dead = false # Death checker, used to stop the player dying multiple times in 1 frame

# object assignment variables
var vine = null # used for checking wall jump nodes
var jumpArea = [] # used for double jump renewels and stuff like water, we're using an array because there may be multiple jump areas colliding

# physics and control managers
@export var locked = false # locks keyboard/gamepad input
@export var lockedPhysics = false # disables physics
@export var overWriteAnimations = false # disables the default animation system

# Object Classes
var Death = load("res://entities/Player/DeathHandler.tscn") # death handler
var Bullet = load("res://entities/Player/Bullet.tscn") 	 # bullet

# Bullet container (used for counting bullets)
@onready var bulletContainer = $BulletContainer







# ready means when the object is first active
func _ready():
	# check Transitions script to figure out how to spawn
	match(Transitions.transType):
		Transitions.TRANS_RELOAD: # file reloading
			# load save position
			position = SaveData.saveData["position"]
			# reset transitions
			Transitions.transType = Transitions.TRANS_NONE
		Transitions.TRANS_AUTO_SAVE: # save on spawn
			SaveData.saveData["position"] = position # set save position
			SaveData.saveData["room"] = Global.room  # set saved room
			# reset transitions
			Transitions.transType = Transitions.TRANS_NONE
			# delay save to prevent the game from creating a thumbnail of the previous room
			await get_tree().process_frame
			await get_tree().process_frame
			# Save data
			SaveData.save()
	# set global player to self (used for referencing in other objects)
	Global.player = self
	if (SaveData.saveData["difficulty"] > 0):
		$Player/Sprite2D/Bow.visible = false




# process is equivelent to a step action, this runs every frame
func _process(_delta):
	# = animation =
	# check that animations aren't being over written
	if (!overWriteAnimations):
		# get the animation node off the player
		var animator = get_node("Player/PlayerAnimator")
		# do some ground checks (remove coyoteTime if you don't want the player to be running in the air)
		if ground || coyoteTime > 0:
			# if movement is 0 then play the idle animation
			if (movement.x == 0):
				animator.play("Idle")
			# else play the walking animation
			else:
				animator.play("Walk")
				# set the sprite scale if the player controls aren't locked
				if (locked):
					var sprite = get_node("Player")
					sprite.scale.x = sign(movement.x)
		# else play air animations
		else:
			# if vine exists then play the wall slide animation
			if (vine != null):
				animator.play("WallSlide")
			# else if movement is goign up then play jump
			elif (movement.y < 0):
				animator.play("Jump")
			# else default to falling
			else:
				animator.play("Fall")
	




# physics (this is where movement actually comes in)
func _physics_process(delta):
	# ignore if physics are locked (alternatively you could use set_physics_process(false) but this could be handy for the animation player)
	if lockedPhysics:
		return
	
	
	# get node containing sounds from the player sprite
	var sfx = get_node("Player/SFX")
	# == Controls / Gameplay ==
	
	
	# cut gravity if jump button is not held or a ceiling was hit
	if (Input.is_action_just_released("gm_jump") && (movement.y < 0) || is_on_ceiling()):
		movement.y *= 0.35
	
	# assign sprite node to a temporary variable (this would be assigned later in the animations but the sprite
	# gets affected by movement direction so we have to assign it now)
	var sprite = get_node("Player")
	# create temporary variable to determine movement directions
	var moveDir = 1
	# if gravity direction is reverse, flip the controls to prevent the player moving oposite to the key,
	# if you're doing more 360 type anti gravity you might want to comment this out
	if gravityDirection.y < 0:
		moveDir = -1
	
	# movements
	# don't change movement on locked (used for vines)
	if !locked:
		# moving right
		if (Input.is_action_pressed("gm_right")):
			# set movement to the player physics walk speed
			movement.x = PlayerPhysics.walkSpeed*moveDir*walkMultiplier
			# make sure the sprite is facing right
			sprite.scale.x = abs(sprite.scale.x)
		# else moving left (this else statement means right takes priority if both are held)
		elif (Input.is_action_pressed("gm_left")):
			# set velocity to the player physics walk speed
			movement.x = -PlayerPhysics.walkSpeed*moveDir*walkMultiplier
			# make sure the sprite is facing left
			sprite.scale.x = -abs(sprite.scale.x)
		#if neither direction is held, stop the player moving
		else:
			movement.x = 0
	
	# vine settings
	# check that a vine node has been assigned and the player isn't on the floor
	if (vine != null && !ground):
		# check that a side variable has been asigned (to determine the direction)
		if (vine.get("side") != null):
			# if side is zero face left
			if vine.side == 0:
				sprite.scale.x = -abs(sprite.scale.x)
			# else face right
			else:
				sprite.scale.x = abs(sprite.scale.x)
		
		# perform the jump
		# quick sum, if left or right is held OR the jump key is pressed then leap off the wall
		if ((Input.is_action_pressed("gm_left") && sprite.scale.x < 0) || (Input.is_action_pressed("gm_right") && sprite.scale.x > 0) || Input.is_action_just_pressed("gm_jump")):
			# disable vine (otherwise the player would stick to the wall, try to keep your masks on the edge of a wall or the player may not reconect)
			vine = null
			# if the jump key isn't being held just let go
			if (Input.is_action_pressed("gm_jump")):
				# set the players movement to bounce off the wall using the plaayer jump strength
				movement = Vector2(PlayerPhysics.walkSpeed*sign(sprite.scale.x)*moveDir,-PlayerPhysics.jumpStrngth)
				# lock the controls to stop the player moving back the next frame
				locked = true
				# play wall jump sound
				sfx.get_node("WallJump").play()
				# stop running for 1/10th of a second, this will force player to leave the wall in a short jump arc
				await get_tree().create_timer(0.1).timeout
				# after the time finishes unlock the controls
				locked = false
	
	# jump area settings
	if (!jumpArea.is_empty()):
		if (jumpArea[0].get("type") != null):
			airJump = PlayerPhysics.totalJumps # only activate if type is in the jump area code

	# coyote timer
	# if aboive 0 decrease the value, delta basically counts al the frames up to a single second, so 1 would reach 0 in 1 second
	if coyoteTime > 0:
		coyoteTime -= delta
	
	
	# ground stuff
	if ground:
		# reset air jumps to total jumps under player physics
		airJump = PlayerPhysics.totalJumps
		# reset movement if it's above 0 (if it's below we want to ignore so the player can jump)
		if (round(movement.y) > 0):
			movement.y = 0
		# reset coyote time
		coyoteTime = PlayerPhysics.COYOTETIME
	else:
		# if not on the ground
		# if on a vine
		if (vine != null):
			# overtake the movement to prevent jittering
			movement.y = PlayerPhysics.vineFall
		# else just apply vertical movement if the falling speed is less then max fall
		elif movement.y < PlayerPhysics.maxFall*gravMultiplier:
			movement.y += PlayerPhysics.gravity*delta*gravMultiplier
		
	
	
	# move the player using movement.y
	# at this point we rotate the movement based on gravity direction, like right gravity would make the player walk on right walls
	velocity = movement.rotated(deg_to_rad(round(rad_to_deg(gravityDirection.angle())-90.0)))
	move_and_slide()
	# set ground to the is_on_floor function
	ground = is_on_floor()
	
	# set up direction to whatever gravity direction is
	up_direction = -gravityDirection
	
	# death button
	if (Input.is_action_just_pressed("gm_die")):
		die()
	
	# debug code
	if (Global.debug):
		# mouse click positions change
		if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
			global_position = get_global_mouse_position()
		
	# if you know what you're doing at this point you could create some orbiting gravitation
	# I would have included this but I fear for the amount of low quality fangames that would come out
	# using it, but I'll give hint, you'll need a 2D raycast to get the ground normal and
	# use rotation (so the player rotates with the slopes and curves) and gravityDirection
	
	

# death hit boxes
func _on_HitMask_body_entered(_body):
	die()
# more death hit boxes
func _on_HitMask_area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	die()

# death function
func die():
	# debug makes you invincible
	if (!Global.debug):
		# if not already dead then continue
		if (!dead):
			# set dead to true to prevent death loops
			dead = true
			# create an instance for the death manager class object
			var dieInst = Death.instantiate()
			# set the death position to our current position
			dieInst.position = position
			# add the object
			get_parent().add_child(dieInst)
			# delete ourselves
			queue_free()
			# run the game over function
			Global.main.game_over()
	else:
		print("Dead")

func _input(event):
	# get node containing sounds from the player sprite
	var sfx = get_node("Player/SFX")
	# Jumping
	# check that jump key is pressed
	if event.is_action_pressed("gm_jump"):
		# check that air jumps is above 0 or if the player is on the floor
		if (airJump > 0 || ground || (jumpArea.size() > 0 && jumpArea[0].get("type")  == null)):
			# Check if on ground or coyoteTime is going
			if (ground || coyoteTime > 0 || (jumpArea.size() > 0 && jumpArea[0].get("type") == null)):
				# Set vertical movement to jump strength
				movement.y = -PlayerPhysics.jumpStrngth*gravMultiplier
				# Play jump sound
				sfx.get_node("Jump").play()
				# Set coyoteTime to 0 to prevent the player from doing normal jumps in the air
				coyoteTime = 0
				# Set air jumps as a back up (used for area jumps)
				airJump = PlayerPhysics.totalJumps
			# perform double jump if we're not on a vine (this prevents using the second jump and wall jump at the same time)
			elif (vine == null):
				# Set vertical movement to the double jump strength
				movement.y = -PlayerPhysics.dJumpStrngth*gravMultiplier
				# Play double jump sound
				sfx.get_node("Jump2").play()
				# remove an air jump from the counter
				airJump -= 1


	# Shooting
	# (we assign the shooting key to action, in case you want the player to do an action other then fire)
	if event.is_action_pressed("gm_action"):
		# make sure bullet container doesn't exceed the amount of bullets on screen
		if (bulletContainer.get_child_count() < PlayerPhysics.TOTAL_BULLETS):
			# play shooting sound effect
			sfx.get_node("Shoot").play()
			
			# create an instance for the bullet using the Bullet class object
			var bull = Bullet.instantiate()
			# set the position (otherwise it will apear at vector 0, 0 )
			bull.global_position = global_position-gravityDirection*2 # we go up 2 pixels to align with the gun, 
			# using gravity direction will move it in the other direction of the gravity
			# match the scale of the bullet to the players (in case you want your bullet to have a more direct facing sprite)
			bull.scale = $Player.scale
			# set the bullets velocity
			bull.velocity = Vector2($Player.scale.x*600,0)
			# finall add the bullet to the scene (note to self: code in a counter)
			bulletContainer.add_child(bull)

# vine checks
func _on_WallJumpMask_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	# set the current vine to the vine variable
	vine = area.get_parent()
	# get the player sprite
	var sprite = get_node("Player")
	# this is the same process in the "vine" area in process, we do the same thing
	# here to prevent the sprite from flicking around
	if (vine.get("side") != null):
		if vine.side == 0:
			sprite.scale.x = -abs(sprite.scale.x)
		else:
			sprite.scale.x = abs(sprite.scale.x)


func _on_WallJumpMask_area_shape_exited(_area_id, area, _area_shape, _self_shape):
	# check that the vine is actually the object we're exiting before removing it
	if (area.get_parent() == vine):
		vine = null


#water checks
func _on_WaterMask_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	# set the current area to the jumpArea variable
	jumpArea.append(area.get_parent())
	# set multipliers
	if (area.get_parent().get("gravMultiplier")):
		if (gravMultiplier != area.get_parent().gravMultiplier):
			movement *= area.get_parent().gravMultiplier
		gravMultiplier = area.get_parent().gravMultiplier
	if (area.get_parent().get("walkMultiplier")):
		walkMultiplier = area.get_parent().walkMultiplier


func _on_WaterMask_area_shape_exited(_area_id, area, _area_shape, _self_shape):
	# check that the jumpArea is actually the object we're exiting before removing it
	if (jumpArea.has(area.get_parent())):
		# check if dark water, if it is dark water, remove the double jumps
		if (area.get_parent().get("type") != null):
			if (area.get_parent().type == 0):
				airJump = 0
			
		jumpArea.erase(area.get_parent())
		# reset multipliers
		if jumpArea.size() == 0:
			gravMultiplier = 1
			walkMultiplier = 1
