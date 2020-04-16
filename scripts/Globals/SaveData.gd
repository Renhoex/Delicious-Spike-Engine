extends Node

#temp data
var saveFileID = 0;

# powers
const POWER_DJUMP = 0;

#save data set up (see func reset_data)
var saveData;
var lastSave;

#var powerList = [1]
var saveThread = Thread.new();

func _ready():
	reset_data();
	#saveFileID = Global.lastFile;
	load_game();

func save():
	var image = get_viewport().get_texture().get_data();
	image.flip_y();
	# wait for the last thread to finish if it's not finished yet to prevent conflicts
	if saveThread.is_active():
		saveThread.wait_to_finish();
	# start new thread to save game and not pause game
	saveThread = Thread.new();
	saveThread.start(self, "_thread_function", image);
	lastSave = saveData.duplicate(true);

func save_death():
	# wait for the last thread to finish if it's not finished yet to prevent conflicts
	if saveThread.is_active():
		saveThread.wait_to_finish();
	saveThread = Thread.new();
	saveThread.start(self, "_thread_function");
	lastSave = saveData.duplicate(true);


func _thread_function(userdata):
	#create and write file
	var save_game = File.new();
	save_game.open("user://save"+String(saveFileID)+".save", File.WRITE);
	save_game.store_line(to_json(saveData));
	save_game.close();
	if userdata:
		userdata.save_png("user://save"+String(saveFileID)+".png");



func _exit_tree():
	if saveThread.is_active():
		saveThread.wait_to_finish();


func load_game():
	var save_game = File.new();
	if not save_game.file_exists("user://save"+String(saveFileID)+".save"):
		return false; # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://save"+String(saveFileID)+".save", File.READ);
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var data = parse_json(save_game.get_line());
		# compare save data (this can stop older versions of your game hitting errors if you update the save data)
		for i in data.keys():
			if saveData.has(i):
				saveData[i] = data[i];
		
	save_game.close();
	var vec = saveData["position"];
	vec = vec.replace("(","").replace(")","").split(",");
	saveData["position"] = Vector2(vec[0],vec[1]);
	lastSave = saveData.duplicate(true);
	return true;

func reset_data():
	#initialize save data
	saveData = { "position" : Vector2.ZERO,
	"room" : "Test",
	"deaths" : 0,
	"time" : 0.0,
	"canDoubleJump" : true,
	"difficulty" : Global.DIFFICULTY_MEDIUM,
	}
	# create temporary data
	lastSave = saveData.duplicate(true);
