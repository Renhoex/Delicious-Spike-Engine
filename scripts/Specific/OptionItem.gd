extends Label
export (int, "SFX", "Music", "VSync", "Display Type", "key Maps", "Auto Key", "Auto Pad", "Back")var type = 0;
var displayNames = ["None", "Heads up display", "On Window"];
var active = false;
onready var options = get_parent().get_parent().get_node("OptionScript");

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
		3: # Options
			text = "Time and Death Display: "+displayNames[Global.counter];
		6: # Pad check
			if (Input.get_connected_joypads().size() == 0):
				# delete option if no pads
				queue_free();
			
			
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
				if Input.is_action_just_released("gm_action"):
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
				if Input.is_action_just_released("gm_action"):
					sound = 0;
				# clamp sound
				sound = clamp(sound,-80,6);
				# set volume
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),sound);
			2: # VSync
				if Input.is_action_just_released("gm_jump"):
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
			4: # key binds (handled in their own script), continue to avoid match mismatch
				continue;
			5, 6: # auto map key
				if (Input.is_action_just_released("gm_jump") && options.autoStart != null && !options.auto):
					# set a check variable
					var found = false;
					var foundEnd = false;
					# find first option
					for i in get_parent().get_child_count():
						if get_parent().get_child(i) == options.autoStart:
							# first option was found
							found = true;
							options.option = i;
						# we make sure found is true first so that the node order isn't messed up
						if get_parent().get_child(i) == options.autoEnd && found:
							foundEnd = true;
					#error check
					if (!found || !foundEnd):
						print("ERROR: could not find first bind option");
					else:
						get_parent().get_child(options.option).activate();
						options.auto = type-4; # 5 will be key, 6 will be pad
						options.locked = true;
						# deactivate self
						active = false;
				
			7: # Back
				if (Input.is_action_just_released("gm_jump")):
					# save config settings
					Global.save_data();
					Global.main.load_room("Menu/FileSelect");
				
