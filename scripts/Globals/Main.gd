extends Node2D

export var debugMode = false;

var isGameOver = false;

func _ready():
	# set the global debug mode
	Global.debug = debugMode;
	# set main to this node
	Global.main = self;
	if Global.counter != 1:
		$HUD/Counters.visible = false;

# load a room with a fade
func load_room_fade(RoomName,fade = 0):
	# check fade, you can add more animations and insert them into this match, by default it does a black fade
	match(fade):
		_:
			$HUD/ScreenFades.play("FadeOut");
	# wait for fade to finish before loading the next room
	yield($HUD/ScreenFades,"animation_finished");
	load_room(RoomName);
	# same as the previous fade, if you want to get more dynamic you can add a second fade variable to the function
	match(fade):
		_:
			$HUD/ScreenFades.play("FadeIn");

# load the new room
func load_room(RoomName):
	# freeze screen to prevent camera jumps
	Global.screen_freeze();
	# find the new room
	var dir = Directory.new();
	if (dir.file_exists("res://rooms/"+RoomName+".tscn")):
		# clear the old room
		for i in $SceneLoader.get_children():
			i.queue_free(); 
		# set the current room to a variable
		Global.room = RoomName;
		# load new room
		var room = load("res://rooms/"+RoomName+".tscn");
		$SceneLoader.add_child(room.instance());
		
	else:
		print("Error: rooms/"+RoomName+".tscn || File did not exist")

# run the game over
func game_over():
	isGameOver = true;
	$GameOver/GameOverText.play("GameOver");
