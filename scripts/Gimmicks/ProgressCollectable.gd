extends Node2D
var collected = false;
export var progressID = 0;

func _ready():
	# if anything other then zero then remove
	if SaveData.saveData["progress"][progressID] != 0:
		queue_free();

func _on_Area2D_body_entered(_body):
	if !(collected):
		# set the progress
		SaveData.saveData["progress"][progressID] = 1;
		collected = true;
		visible = false;
		$Collect.play();
		yield($Collect,"finished");
		queue_free();
