extends Label
export (int, "SFX", "Music", "VSync", "Display Type", "key Maps", "Joy Maps", "Back")var type = 0;
var displayNames = ["None", "Heads up display", "On Window"];
var active = false;

#set texts
func _process(delta):
	# string set
	match(type):
		0: # Sound
			text = "Sound: "+str(round(((AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))+80)/86)*100))+"%";
		1: # Music
			text = "Music: "+str(round(((AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))+80)/86)*100))+"%";
		2: # VSync
			text = "VSync: "+str(OS.vsync_enabled);
		3: #Options
			text = "Time and Death Display: "+displayNames[Global.counter];
	# ative check
	if (active):
		match(type):
			0: # Sound
				var sound = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"));
				# decrease sound
				if Input.is_action_pressed("gm_left"):
					sound -= delta*20;
					if !$SampleSound.playing:
						$SampleSound.play();
				# increse sound
				if Input.is_action_pressed("gm_right"):
					sound += delta*20;
					if !$SampleSound.playing:
						$SampleSound.play();
				# reset sound
				if Input.is_action_just_pressed("gm_action"):
					sound = 0;
				# clamp sound
				sound = clamp(sound,-80,6);
				# set volume
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),sound);
			1: # Music
				var sound = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"));
				# decrease sound
				if Input.is_action_pressed("gm_left"):
					sound -= delta*20;
				# increse sound
				if Input.is_action_pressed("gm_right"):
					sound += delta*20;
				# reset sound
				if Input.is_action_just_pressed("gm_action"):
					sound = 0;
				# clamp sound
				sound = clamp(sound,-80,6);
				# set volume
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),sound);
			2: # VSync
				if Input.is_action_just_pressed("gm_jump"):
					OS.vsync_enabled = !OS.vsync_enabled;
			3: # Counters
				# decrease counter
				if Input.is_action_just_pressed("gm_left"):
					Global.counter -= 1;
				# increse counter
				if Input.is_action_just_pressed("gm_right"):
					Global.counter += 1;
				
				Global.main.get_node("HUD/Counters").visible = (Global.counter == 1);
				Global.counter = fmod(Global.counter,3);
				if Global.counter < 0:
					Global.counter += 3;
			6: # Back
				if Input.is_action_just_pressed("gm_jump"):
					# save config settings
					Global.save_data();
					Global.main.load_room("Menu/FileSelect");
				
