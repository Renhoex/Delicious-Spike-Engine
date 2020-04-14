tool
extends Node2D

export (NodePath)var warpNode;
var warpEnd = null;
var object = null;
const MARGIN = 4; # how many pixels in before activating

func _ready():
	# get destination node
	if (warpNode != ""):
		warpEnd = get_node(warpNode);

func _process(delta):
	# editor help
	if Engine.editor_hint:
		if (warpNode != ""):
			warpEnd = get_node(warpNode);
			update();
	elif object:
		# check if out of camera
		if (object.position.x+MARGIN < Global.currentCamera.limit_left || object.position.x-MARGIN > Global.currentCamera.limit_right || object.position.y+MARGIN < Global.currentCamera.limit_top || object.position.y-MARGIN > Global.currentCamera.limit_bottom):
			# unlick the regular warp script since we aren't loading a new room we don't need to pause the game for a second
			Global.cameraLock = false;
			if (warpEnd != null):
				var warpPos = object.global_position - global_position;
				object.global_position = warpEnd.global_position+warpPos;

func _on_CollisionBox_body_entered(body):
	object = body;
	Global.cameraLock = true;


func _on_CollisionBox_body_exited(body):
	object = null;
	Global.cameraLock = false;

func _draw():
	if Engine.editor_hint && warpEnd:
		draw_circle(warpEnd.global_position-global_position,8,Color.red);
		draw_line(Vector2.ZERO,warpEnd.global_position-global_position,Color(1,1,1,0.25));
