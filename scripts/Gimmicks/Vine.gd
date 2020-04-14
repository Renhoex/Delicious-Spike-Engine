tool
extends Node2D
export (int, "Left", "Right")var side = 0;
export var length = 1.0;

func _ready():
	# set the drawing region to match the length variable
	$Walljump.region_rect = Rect2(Vector2(0,0),Vector2(16,32*length));
	# scale the hitbox too
	$HitBox.scale.y = length;
	# reposition the hitbox to keep the right position
	$HitBox.position.y = 16*length;
	# switch the x scale depending on side
	if side == 0:
		scale.x = -abs(scale.x);
		
func _process(delta):
	# Editor only, we don't want these activating every frame in game.
	# this basically does the same thing as the ready function
	if Engine.editor_hint:
		$Walljump.region_rect = Rect2(Vector2(0,0),Vector2(16,32*length));
		if side == 0:
			scale.x = -1;
		else:
			scale.x = 1;
		$HitBox.scale.y = length;
		$HitBox.position.y = 16*length;
