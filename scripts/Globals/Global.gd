extends Node

var main = null;
var textBuffer = [];
var player = null;
var currentCamera = null;
var room = "Test";
var cameraLock = false;
var reset = false;
var canReset = false;

var debug = false;

const DIFFICULTY_MEDIUM = 0;
const DIFFICULTY_HARD = 1;
const DIFFICULTY_VERY_HARD = 2;
const DIFFICULTY_IMPOSSIBLE = 3;

# config data

var musicVolume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"));
var soundVolume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"));
var vsync = OS.vsync_enabled;

# reload function
func reload(increaseDeath = true):
	# check that a main node has been assigned and that save file is not a negative number
	if (main != null && canReset):
		# reload the data from the last save
		SaveData.saveData = SaveData.lastSave.duplicate(true);
		# reset game over if the game is game over'd
		if main.isGameOver:
			main.get_node("GameOver/GameOverText").play("Resume");
			main.isGameOver = false;
		# set the trnasition to reload so nodes can know it's a reload when the scene loads
		Transitions.transType = Transitions.TRANS_RELOAD;
		# load the room from the save
		main.load_room(SaveData.saveData["room"]);
		# if increase death, increase the counter
		if increaseDeath:
			SaveData.saveData["deaths"] += 1;
			# record deaths
			SaveData.save_death();
		
# freeze the screen
func screen_freeze():
		# capture a screenshot
		var img = get_viewport().get_texture().get_data();
		# most graphics generated in godot are upside down so we need to flip the image
		img.flip_y();
		# create a new texture
		var tex = ImageTexture.new();
		# set the texture to the screenshot
		tex.create_from_image(img);
		# set the screen ghost node to use the texture
		main.get_node("HUD/ScreenGhost").texture = tex;
		main.get_node("HUD/ScreenGhost").modulate = Color(1,1,1,1);
		#delay for one frame
		yield(get_tree(),"idle_frame");
		# run the fade in animation, by default it just immediate fades out
		main.get_node("HUD/FadeGhost").play("FadeIn");

func _process(delta):
	# count game timer
	SaveData.saveData["time"] += delta;
	# if the reload button was pressed then reload
	if Input.is_action_just_pressed("gm_restart"):
		reload();

# change the currently playing song (uses string)
func change_song(songName = null):
	if (Global.main != null):
		if (songName != null):
			Global.main.get_node("Music").stream = load("res://audio/music/"+songName+".ogg");
			Global.main.get_node("Music").play();
		else:
			# if null stop music
			Global.main.get_node("Music").stop();

# change the currently playing song (uses already defined file)
func change_song_stream(song = null):
	if (Global.main != null):
		if (song != null):
			Global.main.get_node("Music").stream = song;
			Global.main.get_node("Music").play();
		else:
			# if null stop music
			Global.main.get_node("Music").stop();

# save configuration data
func save_data(fileID):
	var save_dict = {
		"musicVolume" : AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")),
		"soundVolume" : AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")),
		"vsync" : OS.vsync_enabled,
	}
	
	#create and write file
	var file = File.new();
	file.open("user://Config.conf", File.WRITE);
	file.store_line(to_json(save_dict));
	file.close();
	

# load config data
func load_data():
	var file = File.new();
	if not file.file_exists("user://Config.conf"):
		return false; # Return false as an error

	# read the file
	file.open("user://Config.conf", File.READ);
	# parse each line and set the config data
	while file.get_position() < file.get_len():
		var data = parse_json(file.get_line());
		
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),data["musicVolume"]);
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),data["soundVolume"]);
		OS.vsync_enabled = data["vsync"];
		
	file.close();
	return true;

# game reset
func _input(event):
	if event.is_action_pressed("gm_game_reset") && !reset:
		# this line will reset the game
		get_tree().reload_current_scene();
		# we use reset to prevent the game from reseting every frame
		reset = true;
		Global.main = null;
	elif event.is_action_released("gm_game_reset") && reset:
		reset = false;
