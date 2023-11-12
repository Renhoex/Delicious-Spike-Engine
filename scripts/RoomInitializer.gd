extends Node

@export var music:AudioStream
@export var playOnStart = true
@export var restartSong = false

func _ready():
	# set up scene for testing (play scene or play  custom scene)
	# check if parent is root
	if get_parent() == get_tree().get_root():
		# allow reseting
		Global.canReset = true
		# remember root
		var root = get_parent()
		# allow frame for set up
		await get_tree().process_frame
		# remove self from scene root
		root.remove_child(self)
		# load the main class
		var MainClass = load("res://rooms/Main.tscn")
		var main = MainClass.instantiate()
		# remove any children in scene loader
		for i in main.get_node("SceneLoader").get_children():
			i.queue_free()
		# add main
		root.add_child(main)
		# load self into scene loader
		main.get_node("SceneLoader").add_child(self)
		# set room to room file name (and strip the filename string)
		#Global.room = filename.right(12).left(filename.length()-17)
		
	# load the song if there is one, if there isn't then mute the music
	if (Global.main != null):
		if (music != Global.main.get_node("Music").stream):
			Global.main.get_node("Music").stream = music
			if (playOnStart):
				Global.main.get_node("Music").play()
			else:
				Global.main.get_node("Music").stop()
