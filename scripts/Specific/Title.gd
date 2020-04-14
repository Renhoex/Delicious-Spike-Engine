extends Node

# if start was pressed go to file select
func _input(event):
	if event.is_action_pressed("gm_start"):
		Global.main.load_room("Menu/FileSelect");
