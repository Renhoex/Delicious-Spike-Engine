extends Node
var option = 0;
onready var optionSize = get_parent().get_node("MenuList").get_child_count()-1;

func _process(_delta):
	#for i in get_parent().get_node("MenuList").get_child_count():
	var getNode = get_parent().get_node("MenuList").get_child(option);
	
	get_parent().get_node("Spike").position.y = getNode.rect_position.y+18;
	
	if Input.is_action_just_pressed("gm_down"):
		option += 1;
	if Input.is_action_just_pressed("gm_up"):
		option -= 1;
	
	option = clamp(option,0,optionSize);
