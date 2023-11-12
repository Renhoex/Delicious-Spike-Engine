extends Node

#temp data
var saveFileID = -1 #-1 for testing

# powers
const POWER_DJUMP = 0

#save data set up (see func reset_data)
var saveData
var lastSave

var saveThread = Thread.new()

func _ready():
	reset_data()
	load_game()

func save():
	var image = get_viewport().get_texture().get_image()
	# wait for the last thread to finish if it's not finished yet to prevent conflicts
	if saveThread.is_alive():
		saveThread.wait_to_finish()
	# start new thread to save game and not pause game
	saveThread = Thread.new()
	saveThread.start(Callable(self, "_thread_function").bind(image))
	lastSave = saveData.duplicate(true)
	saveThread.wait_to_finish()
	

func save_death():
	# wait for the last thread to finish if it's not finished yet to prevent conflicts
	if saveThread.is_alive():
		saveThread.wait_to_finish()
	saveThread = Thread.new()
	saveThread.start(Callable(self, "_thread_function"))
	lastSave = saveData.duplicate(true)
	saveThread.wait_to_finish()


func _thread_function(userdata = null):
	#create and write file
	var save_game = FileAccess.open("user://save"+str(saveFileID)+".save", FileAccess.WRITE)
	save_game.store_line(JSON.stringify(saveData))
	save_game.close()
	if userdata:
		userdata.save_png("user://save"+str(saveFileID)+".png")



func _exit_tree():
	if saveThread.is_alive():
		saveThread.wait_to_finish()


func load_game():
	var save_game = FileAccess
	if not save_game.file_exists("user://save"+str(saveFileID)+".save"):
		return false # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game = FileAccess.open("user://save"+str(saveFileID)+".save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		# Get the saved dictionary from the next line in the save file
		var test_json_conv = JSON.new()
		test_json_conv.parse(save_game.get_line())
		var data = test_json_conv.get_data()
		# compare save data (this can stop older versions of your game hitting errors if you update the save data)
		for i in data.keys():
			if saveData.has(i):
				saveData[i] = data[i]
	
	save_game.close()
	
	# convert any remaining strings
	var vec = convert_to_array(saveData["position"])
	saveData["position"] = Vector2(float(vec[0]),float(vec[1]))
	# save current data
	lastSave = saveData.duplicate(true)
	return true

func reset_data():
	#initialize save data
	saveData = { "position" : Vector2.ZERO,
	"room" : "Test",
	"deaths" : 0,
	"time" : 0.0,
	"canDoubleJump" : true,
	"difficulty" : Global.DIFFICULTY_MEDIUM,
	"progress" : [0,0,0,0,0,0,0,0]
	}
	# create temporary data
	lastSave = saveData.duplicate(true)

func convert_to_array(string):
	return string.replace("(","").replace(")","").split(",")
	
