extends Node2D
export var totalBlood = 600;
var Blood = preload("res://entities/Player/BloodParticle.tscn")

func _ready():
	# give a delay, seems like the blood particles stack up if the player's still there for the first frame
	yield(get_tree(),"idle_frame");
	# we're going to use a for loop to spawn the particles all at once
	for i in range(totalBlood):
		# delay the loop by a frame every 16 particles, this makes the explosion last a little longer
		if (fmod(i,16) == 0):
			yield(get_tree(),"idle_frame");
		var blood = Blood.instance();
		# randomly scale the blood particles
		blood.scale *= rand_range(1,1.5);
		# add the blood to the scene
		add_child(blood);
