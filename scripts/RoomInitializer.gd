extends Node

export (AudioStream)var music;
export var playOnStart = true;
export var restartSong = false;

func _ready():
	# load the song if there is one, if there isn't then mute the music
	if (Global.main != null):
		if (music != Global.main.get_node("Music").stream):
			Global.main.get_node("Music").stream = music;
			if (playOnStart):
				Global.main.get_node("Music").play();
			else:
				Global.main.get_node("Music").stop();
