extends KinematicBody2D
# note: this node was built to sync up with objects using velocity and pixelsPerSecond
export (NodePath)var nodeToSync;
onready var getSync = get_node(nodeToSync);

func _physics_process(delta):
	# check that sync is found
	if (getSync != null):
		# sync position
		global_position = getSync.global_position;
		# sync velocities
		# check for velocity
		if (getSync.get("velocity")):
			# check pixels per second
			if (getSync.get("pixelsPerSecond")):
				position += getSync.velocity*getSync.pixelsPerSecond*delta;
			# if pps doesn't exist then use velocity
			else:
				position += getSync.velocity*delta;
