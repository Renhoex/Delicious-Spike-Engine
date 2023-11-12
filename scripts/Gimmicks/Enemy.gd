extends Node2D

@export var health = 10
@export var animationPlayer:NodePath
@export var animationSpawn = "Spawn"
@export var animationHit = "Hit"
@export var animationDeath = "Death"
@onready var animationNode = get_node(animationPlayer)

# play spawn animation on load
func _ready():
	start_animation(animationSpawn)

# function to play animation with error checking built in
func start_animation(anim_name:String):
	if animationNode != null && animationNode.has_method("queue"):
		animationNode.play(anim_name)
	else:
		printerr("Error: Animation not found")

# hurt enemy if bullet has collided
func _on_HitBox_body_entered(body):
	# delete bullet
	body.queue_free()
	if health > 0:
		health -= 1
		start_animation(animationHit)
	else:
		start_animation(animationDeath)
		#delete enemy when animation has finished
		await animationNode.animation_finished
		queue_free()
