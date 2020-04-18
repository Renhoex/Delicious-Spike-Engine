extends "res://scripts/Specific/OptionItem.gd"
export var action = "gm_";
var prefix = "gm_";
var locked = false;
var actionWait = "";
var lastAction = "";

onready var originalString = text;

func _process(_delta):
	if (InputMap.has_action(action) && !locked && actionWait == ""):
		if type == 4: # key
			text = originalString + InputMap.get_action_list(action)[0].as_text();
	# action wait release, used for auto map checking
	if (actionWait != ""):
		# compare action wait and new bind
		if (actionWait != InputMap.get_action_list(lastAction)[0].as_text()):
			actionWait = "";
			lastAction = "";
			activate();
	elif (!options.auto):
		if (active && !locked):
			if (Input.is_action_just_released("gm_jump")):
				activate();

func activate():
	text = originalString + ".."
	options.locked = true;
	locked = true;

func _unhandled_key_input(event):
	if (locked):
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
		# if last node stop auto
		if (options.autoEnd == self):
			options.auto = false;
			options.locked = false;
		# go next node if auto
		elif (options.auto):
			# deactivate self
			active = false;
			# get next option
			options.option += 1;
			var next = get_parent().get_child(options.option);
			next.actionWait = event.as_text();
			next.lastAction = action;
			next.text = next.originalString + "..";
		#delay 2 frames to prevent option changes on up and down movements
		yield(get_tree(),"idle_frame");
		yield(get_tree(),"idle_frame");
		# unlock options if not auto
		if (!options.auto):
			options.locked = false;
	elif (active && actionWait != ""):
		actionWait = event.as_text();
		

