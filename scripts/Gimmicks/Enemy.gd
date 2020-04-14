extends Node2D

export var health = 10;
export (NodePath)var animationPlayer;
export (String)var animationSpawn = "Spawn";
export (String)var animationHit = "Hit";
export (String)var animationDeath = "Death";
onready var animationNode = get_node(animationPlayer);

# play spawn animation on load
func _ready():
	play_animation(animationSpawn);

# function to play animation with error checking built in
func play_animation(name):
	if animationNode != null && animationNode.has_method("queue"):
		animationNode.play(name);
	else:
		print("Error: Animation not found");

# hurt enemy if bullet has collided
func _on_HitBox_body_entered(body):
	# delete bullet
	body.queue_free();
	if health > 0:
		health -= 1;
		play_animation(animationHit);
	else:
		play_animation(animationDeath);
		#delete enemy when animation has finished
		yield(animationNode,"animation_finished");
		queue_free();
