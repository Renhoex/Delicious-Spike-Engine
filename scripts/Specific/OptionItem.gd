extends Label
export (int, "SFX", "Music", "VSync", "Display Type", "Button Maps", "Joy Maps", "Back")var type = 0;

#set texts
func _process(_delta):
	match(type):
		2: # VSync
			text = "VSync: "+str(OS.vsync_enabled);
