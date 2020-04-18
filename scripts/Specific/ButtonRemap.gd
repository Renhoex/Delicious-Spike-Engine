extends "res://scripts/Specific/OptionItem.gd"
export var action = "gm_";
var prefix = "gm_";
var locked = false;
var pressed = false;

onready var originalString = text;
onready var options = get_parent().get_parent().get_node("OptionScript");

func _process(_delta):
	if (InputMap.has_action(action) && !locked):
		if type == 4: # key
			text = originalString + InputMap.get_action_list(action)[0].as_text();
	if (active && !locked):
		if (Input.is_action_just_pressed("gm_jump")):
			text = originalString + ".."
			options.locked = true;
			locked = true;
			pressed = true;
	elif (Input.is_action_just_released("gm_jump")):
		pressed = false;

func _unhandled_key_input(event):
	if (locked && !pressed):
		var rememberGamepad = InputMap.get_action_list(action)[1];
		# check through actions for any duplicates then remap that action to this one
		for i in InputMap.get_actions():
			# check for prefixes and inputs match
			if (str(i).begins_with(prefix) && event.as_text() == InputMap.get_action_list(i)[0].as_text() && i != action):
				var rememberSwapGamepad = InputMap.get_action_list(i)[1];
				# erase end point (i is the action)
				InputMap.action_erase_events(i);
				# set end point
				InputMap.action_add_event(i, InputMap.get_action_list(action)[0]);
				InputMap.action_add_event(i, rememberSwapGamepad);
		# erase inputs
		InputMap.action_erase_events(action);
		# set to new key
		InputMap.action_add_event(action, event);
		# set old gamepad button (we don't want to lose the inputs)
		InputMap.action_add_event(action, rememberGamepad);
		#unlock node
		locked = false;
		#delay 2 frames to prevent duplicate inputs
		yield(get_tree(),"idle_frame");
		yield(get_tree(),"idle_frame");
		# unlock options
		options.locked = false;
