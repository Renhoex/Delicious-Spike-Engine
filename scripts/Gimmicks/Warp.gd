extends Node2D

@export var room = ""

# super simple, if the player enters the box then change room, game acts weird if we don't delay the reaction
func _on_Area2D_body_entered(_body):
	await get_tree().process_frame
	Global.main.load_room(room)
