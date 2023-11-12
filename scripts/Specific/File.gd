@tool
extends Node2D

@onready var commandText = $TextContainer/CommandText
@onready var icon = $FileIcon
@export_enum("File 1", "File 2", "File 3")var fileID = 0
var difficultyOptions = ["Medium","Hard","Very Hard","Impossible"]

func _ready():
	# don't execute if in editor
	if not Engine.is_editor_hint():
		# set the file to the node name
		commandText.text = name.replace("_"," ")
		# check that the file exists
		var path = "user://save"+str(fileID)+".png"
		var img = Image.new()
		# error check
		var err = 1
		# see if err can load image
		if (FileAccess.file_exists(path)):
			err = img.load(path)
		
		if err != 0:
			print("Save file not found || Using new file icon")
		else:
			# replace the file icon with the save screenshot
			var tex = ImageTexture.create_from_image(img)
			tex.set_size_override(icon.size)
			icon.texture = tex
	
		# remember the file ID before getting the data
		var preFile = SaveData.saveFileID
		SaveData.saveFileID = fileID
		# clean data in case the data does not exist
		SaveData.reset_data()
		if (SaveData.load_game()):
			var time = SaveData.saveData["time"]
			
			# calculate time
			var hours   = floor((time / 60) / 60)
			var minutes = floor(fmod(time / 60.0, 60))
			var seconds = floor(fmod(time, 60.0))
			var milli = fmod(time,1.0)
			$TextContainer/Time.text = "Time: " + ("%02d" % hours)+":"+("%02d" % minutes)+":"+("%02d" % seconds)+("%0.2f" % milli).right(1)
			# set deaths
			$TextContainer/Deaths.text = "Deaths: " + str(SaveData.saveData["deaths"])
			
			
			$TextContainer/Difficulty.text = difficultyOptions[SaveData.saveData["difficulty"]]
		
		# we still set these since they're visible by default
		# set visibility of menu icons when collected
		for i in $ProgressContainer.get_child_count():
			if !SaveData.saveData["progress"][i]:
				# set modulate to be transparent, otherwise grid container will auto sort
				# if you prever auto sort then set to visible = false
				$ProgressContainer.get_child(i).modulate = Color(0,0,0,0)
		
		# reset the file ID
		SaveData.saveFileID = preFile
	
#reflect the node name in the editor
func _process(_delta):
	if Engine.is_editor_hint():
		$TextContainer/CommandText.text = name.replace("_"," ")
