tool
extends Node2D

export (int, "Medium", "Hard", "Very Hard")var difficulty = 1;

func _ready():
	# delete if save file is higher then our difficulty
	if SaveData.saveData["difficulty"] > difficulty:
		queue_free();
	_on_Save_frame_changed();

func _process(_delta):
	# change the save icon in the editor
	if Engine.editor_hint:
		if difficulty == 0:
			$Save.frame = 2;
		else:
			$Save.frame = 0;

# if an object with the player bullet mask interacts run the save procedure
func _on_Area2D_body_entered(_body):
	var playRef = weakref(Global.player);
	if (playRef.get_ref()):
		SaveData.saveData["position"] = Global.player.position;
		SaveData.saveData["room"] = Global.room;
		$AnimationPlayer.play("Save");
		SaveData.save();

# increase whatever the current frame is by 2 if on medium
func _on_Save_frame_changed():
	if difficulty == 0 && !Engine.editor_hint:
		if ($Save.frame+2 < $Save.vframes*$Save.hframes):
			$Save.frame += 2;
