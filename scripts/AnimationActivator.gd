tool
extends Area2D

export (NodePath)var animationPlayer;
export (String)var animationName;

export var animationHintList = PoolStringArray(); 
# wanted to make animationName into a drop down list
# but I couldn't figure out how to make it work 
# and update, so for now you can just copy these into animationName
# to save time

onready var animationNode = get_node(animationPlayer);
export var repeat = false;
var active = false;

func _process(_delta):
	if Engine.editor_hint && animationPlayer != "":
		animationNode = get_node(animationPlayer);
		if animationNode != null && animationNode.has_method("get_animation_list"):
			animationHintList = animationNode.get_animation_list();
		else:
			animationHintList = ["Error: Node not found"];

# when an object activates the trigger, run the associated animation
func _on_TrapActivator_body_entered(_body):
	# error check
	if animationNode != null && animationNode.has_method("queue"):
		if (!active || repeat):
			# queue will add the animation to a list of current animations waiting to play
			animationNode.queue(animationName);
			active = true;
	else:
		print("Error: Animation not found");
