extends Node2D
@export var totalBlood = 600
var bloodCount = totalBlood
var Blood = preload("res://entities/Player/BloodParticle.tscn")

func _process(_delta):
	# us blood count
	if bloodCount > 0:
		# loop through blood and bursts for about 16 frames
		for _i in range(totalBlood/16.0):
			# create a new blood instance
			var blood = Blood.instantiate()
			# randomly scale the blood particles
			blood.scale *= randf_range(1,1.5)
			# add the blood to the scene
			add_child(blood)
			# down the blood count
			bloodCount -= 1
	else:
		# stop functioning
		set_process(false)
