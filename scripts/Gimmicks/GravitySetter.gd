tool
extends Node2D
export (int, "up", "down")var direction = 0;


func _ready():
	if direction != 0:
		rotation = deg2rad(90);
	else:
		rotation = deg2rad(-90);

func _process(_delta):
	if Engine.editor_hint:
		if direction != 0:
			rotation = deg2rad(90);
		else:
			rotation = deg2rad(-90);
		

func _on_Hitbox_body_entered(body):
	if direction != 0:
		# check if gravity direction doesn't match
		if (body.gravityDirection != Vector2.DOWN):
			$FlipSound.play();
			body.scale.y = abs(body.scale.y);
			# flip all nodes in the reverse gravity group
			for i in get_tree().get_nodes_in_group("ReverseGravity"):
				i.scale.y = abs(i.scale.y);
			body.gravityDirection = Vector2.DOWN;
			# reverse players vertical velocity
			body.velocity.y = -body.velocity.y;
	else:
		# check if gravity direction doesn't match
		if (body.gravityDirection != Vector2.UP):
			$FlipSound.play();
			body.scale.y = -abs(body.scale.y);
			# flip all nodes in the reverse gravity group
			for i in get_tree().get_nodes_in_group("ReverseGravity"):
				i.scale.y = -abs(i.scale.y);
			body.gravityDirection = Vector2.UP;
			#reverse players vertical velocity
			body.velocity.y = -body.velocity.y;
