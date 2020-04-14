extends Node2D

export var warpIndex = 0;
export var room = "";
var object = null;
const MARGIN = 4; # how many pixels in before activating

func _ready():
	if (Global.player && Transitions.warpIndex == warpIndex):
		Global.player.global_position = global_position+Transitions.warpPos;
		Transitions.warpIndex = -1;

func _process(delta):
	if object:
		# check if out of camera
		if (object.position.x+MARGIN < Global.currentCamera.limit_left || object.position.x-MARGIN > Global.currentCamera.limit_right || object.position.y+MARGIN < Global.currentCamera.limit_top || object.position.y-MARGIN > Global.currentCamera.limit_bottom):
			# Game acts weird if we don't wait a frame
			yield(get_tree(),"idle_frame");
			Global.cameraLock = false;
			# set transitons
			Transitions.warpIndex = warpIndex;
			Transitions.warpPos = object.global_position - global_position;
			Global.main.load_room(room);

# set player body
func _on_CollisionBox_body_entered(body):
	object = body;
	Global.cameraLock = true;

# remove player
func _on_CollisionBox_body_exited(body):
	object = null;
	Global.cameraLock = false;
