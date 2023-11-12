extends Node
var option = 0
@onready var optionSize
var locked = false
var auto = 0
@export var rebindStart:NodePath
@export var rebindEnd:NodePath
@onready var autoStart = get_node(rebindStart)
@onready var autoEnd = get_node(rebindEnd)

func _process(_delta):
	optionSize = get_parent().get_node("MenuList").get_child_count()
	var getNode = get_parent().get_node("MenuList").get_child(option)
	getNode.active = true
	get_parent().get_node("Spike").position.y = getNode.position.y+18
	if (!locked):
		if Input.is_action_just_pressed("gm_down"):
			getNode.active = false
			option += 1
		if Input.is_action_just_pressed("gm_up"):
			getNode.active = false
			option -= 1
	
	option = fmod(option,optionSize)
	# reverse loop fix
	if option < 0:
		option += optionSize
