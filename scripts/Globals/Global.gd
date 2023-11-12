extends Node

var main = null
var textBuffer = []
var player = null
var currentCamera = null
var room = "Test"
var cameraLock = false
var reset = false
var canReset = false

var debug = true

const DIFFICULTY_MEDIUM = 0
const DIFFICULTY_HARD = 1
const DIFFICULTY_VERY_HARD = 2
const DIFFICULTY_IMPOSSIBLE = 3

# config data

var musicVolume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
var soundVolume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
var vsync = (DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED)
var counter = 0

# load config data
func _ready():
	load_data()

# reload function
func reload(increaseDeath = true):
	# check that a main node has been assigned and that save file is not a negative number
	if (main != null && canReset):
		# don't reload time
		var rememberTime = SaveData.saveData["time"]
		# reload the data from the last save
		SaveData.saveData = SaveData.lastSave.duplicate(true)
		# reset game over if the game is game over'd
		if main.isGameOver:
			main.get_node("GameOver/GameOverText").play("Resume")
			main.isGameOver = false
		# set the trnasition to reload so nodes can know it's a reload when the scene loads
		Transitions.transType = Transitions.TRANS_RELOAD
		# load the room from the save
		main.load_room(SaveData.saveData["room"])
		# if increase death, increase the counter
		if increaseDeath:
			SaveData.saveData["deaths"] += 1
			SaveData.saveData["time"] = rememberTime
			# record deaths
			SaveData.save_death()
		
# freeze the screen
func screen_freeze():
		# capture a screenshot
		var img = get_viewport().get_texture().get_image()
		# create a new texture
		# set the texture to the screenshot
		var tex = ImageTexture.create_from_image(img)
		# set the screen ghost node to use the texture
		main.get_node("HUD/ScreenGhost").texture = tex
		main.get_node("HUD/ScreenGhost").modulate = Color(1,1,1,1)
		#delay for one frame
		await get_tree().process_frame
		# run the fade in animation, by default it just immediate fades out
		main.get_node("HUD/FadeGhost").play("FadeIn")

# count time and death
func _process(delta):
	# exclude rooms in the menu folder or if the save file id is fake
	if (!room.begins_with("Menu/") && SaveData.saveFileID > -1):
		# count game timer
		SaveData.saveData["time"] += delta
		
		if counter > 0:
			var time = SaveData.saveData["time"]
			# calculate time
			var hours   = floor((time / 60) / 60)
			var minutes = floor(fmod(time / 60.0, 60))
			var seconds = floor(fmod(time, 60.0))
			var milli = fmod(time,1.0)
			
			if counter == 1:
				main.get_node("HUD/Counters/Time").text = ("%02d" % hours)+":"+("%02d" % minutes)+":"+("%02d" % seconds)+("%0.2f" % milli).right(1)
				main.get_node("HUD/Counters/Death").text = str(SaveData.saveData["deaths"])
			else:
				var caption = ProjectSettings.get_setting("application/config/name")
				caption += " | Deaths: " + str(SaveData.saveData["deaths"])
				caption += " | Time: " + ("%02d" % hours)+":"+("%02d" % minutes)+":"+("%02d" % seconds)+("%0.2f" % milli).right(1)
				
				get_window().set_title(caption)
				
			
		# if the reload button was pressed then reload
		if Input.is_action_just_pressed("gm_restart"):
			reload()

# change the currently playing song (uses string)
func change_song(songName = null):
	if (Global.main != null):
		if (songName != null):
			Global.main.get_node("Music").stream = load("res://audio/music/"+songName+".ogg")
			Global.main.get_node("Music").play()
		else:
			# if null stop music
			Global.main.get_node("Music").stop()

# change the currently playing song (uses already defined file)
func change_song_stream(song = null):
	if (Global.main != null):
		if (song != null):
			Global.main.get_node("Music").stream = song
			Global.main.get_node("Music").play()
		else:
			# if null stop music
			Global.main.get_node("Music").stop()

# save configuration data
func save_data():
	
	var file = ConfigFile.new()
		
	file.set_value("sound","musicVolume",AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	file.set_value("sound","soundVolume",AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	file.set_value("video","vsync",(DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED))
	# save inputs
	var actionCount = 0
	for i in InputMap.get_actions(): # input names
		actionCount = 0
		for j in InputMap.action_get_events(i): # the keys
			# key storage is complex, here we keep a record of keys, gamepad buttons and gamepad axis's
			# prefix keys: K = Key, B = joypad Button, A = Axis, V = AxisValue
			if j is InputEventKey:
				file.set_value("controls","K"+str(actionCount)+i,j.get_keycode_with_modifiers())
			elif j is InputEventJoypadButton:
				file.set_value("controls","B"+str(actionCount)+i,j.button_index)
			elif j is InputEventJoypadMotion:
				file.set_value("controls","A"+str(actionCount)+i,j.axis)
				file.set_value("controls","V"+str(actionCount)+i,j.axis_value)
			# incease counters (prevents conflicts)
			actionCount += 1
	# save config and close
	file.save("user://Config.cfg")
	

# load config data
func load_data():
	var file = ConfigFile.new()
	var err = file.load("user://Config.cfg")
	if err != OK:
		return false # Return false as an error

	# load volumes
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),file.get_value("sound","musicVolume",AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),file.get_value("sound","soundVolume",AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (file.get_value("video","vsync",(DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED))) else DisplayServer.VSYNC_DISABLED)
	counter = file.get_value("display","counters",counter)
	
	# load inputs
	var actionCount = 0
	for i in InputMap.get_actions(): # loop through input names
		
		# prefix keys: K = Key, B = joypad Button, A = Axis, V = AxisValue
		
		# check for any inputs, if any are found then remove binding
		if (file.has_section_key("controls","K0"+i) || 
		file.has_section_key("controls","B0"+i) ||
		file.has_section_key("controls","A0"+i) || 
		file.has_section_key("controls","V0"+i)):
			# clear input
			InputMap.action_erase_events(i)
		# check prefixes
		while (file.has_section_key("controls","K"+str(actionCount)+i) || 
		file.has_section_key("controls","B"+str(actionCount)+i) ||
		file.has_section_key("controls","A"+str(actionCount)+i) || 
		file.has_section_key("controls","V"+str(actionCount)+i)):
			
			# keyboard check
			if (file.has_section_key("controls","K"+str(actionCount)+i)):
				# define new key
				var getInput = InputEventKey.new()
				# grab scancode
				getInput.keycode = file.get_value("controls","K"+str(actionCount)+i)
				# set new input
				InputMap.action_add_event(i,getInput)
			# joypad button check
			if (file.has_section_key("controls","B"+str(actionCount)+i)):
				# define new key
				var getInput = InputEventJoypadButton.new()
				# grab button index
				getInput.button_index = file.get_value("controls","B"+str(actionCount)+i)
				# set new input
				InputMap.action_add_event(i,getInput)
			# joypad Axis check
			if (file.has_section_key("controls","A"+str(actionCount)+i) &&
			file.has_section_key("controls","V"+str(actionCount)+i)):
				# define new key
				var getInput = InputEventJoypadMotion.new()
				# grab axis
				getInput.axis = file.get_value("controls","A"+str(actionCount)+i)
				getInput.axis_value = file.get_value("controls","V"+str(actionCount)+i)
				# set new input
				InputMap.action_add_event(i,getInput)
			
			actionCount += 1
		# reset action counter
		actionCount = 0
	return true

# game reset
func _input(event):
	if event.is_action_pressed("gm_game_reset") && !reset:
		# this line will reset the game
		var isReset = get_tree().reload_current_scene()
		# we use reset to prevent the game from reseting every frame
		if (isReset == 0):
			reset = true
			Global.main = null
			# reset save
			SaveData.saveFileID = -1
			# reset window caption
			get_window().set_title(ProjectSettings.get_setting("application/config/name"))
		else:
			print("Reset failed")
	elif event.is_action_released("gm_game_reset") && reset:
		reset = false
