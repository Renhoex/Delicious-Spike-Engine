extends Node

@export var fileNodes: Array[NodePath]
@export var newGameRoom = "Test"
var file = 0
var menu = MENU_FILE_SELECT
var menuOption = 0
@onready var playerNode = get_node("../Player")

# strings for the file menu
var fileOptions = ["  Load >","< New Game  "]
# check file.gd if you want to rename the difficulties
var difficultyOptions = ["  Medium >","< Hard >","< Very Hard >","< Impossible  "]

const MENU_FILE_SELECT = 0
const MENU_FILE_OPTIONS = 1
const MENU_FILE_NEW_GAME = 2

func _process(delta):
	# Only run code if menu's value matches
	match(menu):
		# File select handling
		MENU_FILE_SELECT: # selecting a file
			# file switching
			file = option_change(file,fileNodes.size()-1)
		MENU_FILE_OPTIONS: # what to do with the file
			# option switching (using the length of strings)
			menuOption = option_change(menuOption,fileOptions.size()-1)
			# check that the node exists and has the command text node to write in
			if (!fileNodes[file].is_empty()):
				if get_node(str(fileNodes[file])).get("commandText"):
					# write the command
					get_node(str(fileNodes[file])).commandText.text = fileOptions[menuOption]
		MENU_FILE_NEW_GAME: # difficulty select
			# use the difficulty options to determine the difficulty (basically you want as many strigns in difficultyOptions as there are difficulties)
			menuOption = option_change(menuOption,difficultyOptions.size()-1)
			# same process as before
			if (!fileNodes[file].is_empty()):
				if get_node(str(fileNodes[file])).get("commandText"):
					get_node(str(fileNodes[file])).commandText.text = difficultyOptions[menuOption]
	
	# for the purposes of the menu we're going to use jump as the accept action
	if Input.is_action_just_pressed("gm_jump"):
		match(menu):
			MENU_FILE_SELECT:
				# set the save file to match the file
				SaveData.saveFileID = file
				# check if a save file already exists
				var save_check = FileAccess
				if not save_check.file_exists("user://save"+str(file)+".save"):
					# if no save file was found then go to the new game menu
					menu = MENU_FILE_NEW_GAME
					menuOption = 1 # set to 1 for hard
				else:
					# otherwise ask if they want to start a new game or load
					menu = MENU_FILE_OPTIONS
					menuOption = 0 # set to 0 for load, 1 for new game by default
			MENU_FILE_NEW_GAME: # new game selection
				# reset data
				SaveData.reset_data()
				# make the difficulty match the option
				SaveData.saveData["difficulty"] = menuOption
				# set transition to auto save to indicate a new game
				Transitions.transType = Transitions.TRANS_AUTO_SAVE
				# enable reseting
				Global.canReset = true
				# load new game room
				Global.main.load_room(newGameRoom)
			MENU_FILE_OPTIONS: # save game loading
				match(menuOption):
					0: #load game
						SaveData.load_game()
						#enable resets now that data has been loaded
						Global.canReset = true
						# reload and make sure not to increase the death counter
						Global.reload(false)
					1: #new game
						# go to the new game interface
						menu = MENU_FILE_NEW_GAME
						# reset timer
						SaveData.saveData["time"] = 0.0
						# reset death
						SaveData.saveData["deaths"] = 0
						menuOption = 1 # set to hard by default
		
	
	# check that the current file node exists
	if (!fileNodes[file].is_empty()):
		# if it does then move the player towards the files x position
		playerNode.position.x = lerp(playerNode.position.x,get_node(fileNodes[file]).position.x,delta*5)
	
	# options
	if Input.is_action_just_pressed("gm_up"):
		Global.main.load_room("Menu/Options")

func option_change(optionToChange, limits):
	var result = optionToChange
	if Input.is_action_just_pressed("gm_right"):
		# if less then limit, increase, otherwise loop to 0
		if result < limits:
			result += 1
		else:
			result = 0
	elif Input.is_action_just_pressed("gm_left"):
		# if greater then 0, decrease, otherwise loop to limit
		if result > 0:
			result -= 1
		else:
			result = limits
	return result
