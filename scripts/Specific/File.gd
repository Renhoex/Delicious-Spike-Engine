tool
extends Node2D

onready var commandText = $TextContainer/CommandText;
onready var icon = $FileIcon;
export (int, "File 1", "File 2", "File 3")var fileID = 0;

func _ready():
	# don't execute if in editor
	if not Engine.editor_hint:
		# set the file to the node name
		commandText.text = name.replace("_"," ");
		# check that the file exists
		var path = "user://save"+String(fileID)+".png";
		var img = Image.new();
		var err = img.load(path);
		if err != 0:
			print("Save file not found || Using new file icon");
		else:
			# replace the file icon with the save screenshot
			var tex = ImageTexture.new();
			var settings = icon.texture.flags;
			tex.create_from_image(img,settings);
			tex.set_size_override(icon.rect_size);
			icon.texture = tex;
	
		# remember the file ID before getting the data
		var preFile = SaveData.saveFileID;
		SaveData.saveFileID = fileID;
		# clean data in case the data does not exist
		SaveData.reset_data();
		SaveData.load_game();
		var time = SaveData.saveData["time"];
		
		# calculate time
		var hours   = floor((time / 60) / 60);
		var minutes = floor(fmod(time / 60.0, 60));
		var seconds = floor(fmod(time, 60.0));
		$TextContainer/Time.text = "Time: " + str(hours) + ":" + str(minutes) + ":" + str(seconds);
		# set deaths
		$TextContainer/Deaths.text = "Deaths: " + str(SaveData.saveData["deaths"]);
		# reset the file ID
		SaveData.saveFileID = fileID;
	
#reflect the node name in the editor
func _process(delta):
	if Engine.editor_hint:
		$TextContainer/CommandText.text = name.replace("_"," ");
