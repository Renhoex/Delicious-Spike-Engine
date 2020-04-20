extends "res://scripts/Specific/OptionItem.gd"
export var action = "gm_";
var prefix = "gm_";
var locked = false;
var actionWait = "";
var lastAction = "";
# assinging jump to an already existing jump key will get the action stuck in a loop
# assigningJump is used to prevent a loop
var assigningJump = false;

onready var originalString = text;

# NOTE: current system I have set up only accounts for 2 inputs for event inputs, 
# first one is key, second one is joypad, order is important
# there is a way to improve this code and I'll optimize it myself in the next release

func _process(_delta):
	if (InputMap.has_action(action) && !locked && actionWait == ""):
		if type == 4: # key
			text = originalString
			for i in InputMap.get_action_list(action):
				text += event_to_text(i);
				# check if last
				if (i != InputMap.get_action_list(action)[InputMap.get_action_list(action).size()-1]):
					text += ", ";
	
	# action wait release, used for auto map checking
	if (actionWait != ""):
		# compare action wait and new bind
		if (actionWait != event_to_text(InputMap.get_action_list(lastAction)[options.auto-1])):
			actionWait = "";
			lastAction = "";
			activate();
	# bind key if not locked
	elif (!options.auto):
		if (active && !locked):
			if (Input.is_action_just_released("gm_jump")):
				# check if we were already assigning jump
				if (!assigningJump):
					activate();
				else:
				# if we have then just release
					assigningJump = false;
	

func activate():
	text = originalString + ".."
	options.locked = true;
	locked = true;

# key binds
func _unhandled_key_input(event):
		# auto 1 is key
	if (locked && (options.auto == 0 || options.auto == 1)):
		var rememberGamepad = InputMap.get_action_list(action)[1];
		
		# check through actions for any duplicates then remap that action to this one if a duplicate exists
		for i in InputMap.get_actions():
			# check for prefixes and inputs match
			if (str(i).begins_with(prefix) && event.as_text() == InputMap.get_action_list(i)[0].as_text() && i != action):
				var rememberSwapGamepad = InputMap.get_action_list(i)[1];
				# erase end point (i is the action)
				InputMap.action_erase_events(i);
				# set end point
				InputMap.action_add_event(i, InputMap.get_action_list(action)[0]);
				InputMap.action_add_event(i, rememberSwapGamepad);
		
		# check if already current action
		if (event.as_text() != InputMap.get_action_list(action)[0].as_text()):
			# erase inputs
			InputMap.action_erase_events(action);
			# set to new key
			InputMap.action_add_event(action, event);
			# set old gamepad button (we don't want to lose the inputs)
			InputMap.action_add_event(action, rememberGamepad);
		# check if action is jump (loop prevention)
		elif (action == "gm_jump"):
			assigningJump = true;

		#unlock node
		unlock_node(event);
	# update actionWait if auto
	elif (active && actionWait != ""):
		actionWait = event_to_text(event);

# button binds
func _input(event):
	if event is InputEventJoypadButton || event is InputEventJoypadMotion:
		# auto 2 is gamepad
		if (locked && (options.auto == 0 || options.auto == 2)):
			var rememberKey = InputMap.get_action_list(action)[0];
			# check through actions for any duplicates then remap that action to this one if a duplicate exists
			for i in InputMap.get_actions():
				# check if there's more then 1 input
				if InputMap.get_action_list(i).size() > 1:
					# check for prefixes and inputs match
					if (str(i).begins_with(prefix) && event_to_text(event) == event_to_text(InputMap.get_action_list(i)[1]) && i != action):
						var rememberSwapKey = InputMap.get_action_list(i)[0];
						# erase end point (i is the action)
						InputMap.action_erase_events(i);
						# set end point
						InputMap.action_add_event(i, rememberSwapKey);
						InputMap.action_add_event(i, InputMap.get_action_list(action)[1]);
			
			# check if already current action
			if (event_to_text(event) != event_to_text(InputMap.get_action_list(action)[1])):
				# erase inputs
				InputMap.action_erase_events(action);
				# set old key input
				InputMap.action_add_event(action, rememberKey);
				# set to new button
				InputMap.action_add_event(action, event);
			# check if action is jump (loop prevention)
			elif (action == "gm_jump"):
				assigningJump = true;
			
			#unlock node
			unlock_node(event);
		# update actionWait if auto
		elif (active && actionWait != ""):
			actionWait = event_to_text(event);


func unlock_node(event):
	locked = false;
	# if last node stop auto
	if (options.autoEnd == self):
		options.auto = 0;
		options.locked = false;
	# go next node if auto
	elif (options.auto):
		# deactivate self
		active = false;
		# get next option
		options.option += 1;
		var next = get_parent().get_child(options.option);
		next.actionWait = event_to_text(event);
		next.lastAction = action;
		next.text = next.originalString + "..";
	#delay 2 frames to prevent option changes on up and down movements
	yield(get_tree(),"idle_frame");
	yield(get_tree(),"idle_frame");
	# unlock options if not auto
	if (!options.auto):
		options.locked = false;


# takes an event and returns it as text
func event_to_text(event):
	if event is InputEventKey:
		return event.as_text();
	if event is InputEventJoypadButton:
		return "Button: "+str(event.button_index);
	if event is InputEventJoypadMotion:
		return "(axis: "+str(event.axis)+", value: "+str(event.axis_value)+")";
	
