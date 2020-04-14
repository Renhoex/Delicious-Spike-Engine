tool
extends Node2D
onready var spriteTop = $WaterTop;
onready var spriteBottom = $WaterTop/Water;
var light = preload("res://graphics/Gimmicks/WaterLight.png"); # light water graphie
var lightTop = preload("res://graphics/Gimmicks/WaterLightTop.png"); # top light water
export (int, "Dark", "Light", "Space")var type = 0; #water types
export var gravMultiplier = 0.75; #gravity modifier
export var walkMultiplier = 0.75; #walking modifier

func _ready():
	if !Engine.editor_hint:
		# this uses some math that would take a bit too long to explain,
		# the short of it is this code chunk keeps the water at the top and 
		# changes the region rect to match the nodes scale
		spriteTop.region_rect = Rect2(Vector2(0,0),Vector2(32*scale.x,32*min(scale.y,1)));
		spriteBottom.region_rect = Rect2(Vector2(0,0),Vector2(32*scale.x,32*max(0,scale.y-1)));
		spriteTop.global_scale = Vector2(1,1);
		spriteBottom.visible = (scale.y > 0);
		spriteTop.global_position.y = global_position.y-max(0,scale.y-1)*16;
		spriteBottom.position.y = 16*max(0,scale.y-1)+16;
		# change the texture if type is light water, if space then just hide the water sprites
		match(type):
			1: #Light Water
				$WaterTop.texture = lightTop;
				$WaterTop/Water.texture = light;
			2: #Space
				$WaterTop.visible = false;
				$WaterTop/Water.visible = false;
		
func _process(delta):
	# Editor only, we don't want these activating every frame in game.
	# same as ready but with some additional code
	if Engine.editor_hint:
		$WaterTop.region_rect = Rect2(Vector2(0,0),Vector2(32*scale.x,32*min(scale.y,1)));
		$WaterTop/Water.region_rect = Rect2(Vector2(0,0),Vector2(32*scale.x,32*max(0,scale.y-1)));
		$WaterTop.global_scale = Vector2(1,1);
		$WaterTop/Water.visible = (scale.y > 0);
		$WaterTop.global_position.y = global_position.y-max(0,scale.y-1)*16;
		$WaterTop/Water.position.y = 16*max(0,scale.y-1)+16;
		match(type):
			0: #Light Water
				$WaterTop.texture = load("res://graphics/Gimmicks/WaterTop.png")
				$WaterTop/Water.texture = load("res://graphics/Gimmicks/Water.png");
			1: #Light Water
				$WaterTop.texture = lightTop;
				$WaterTop/Water.texture = light;
			2: #Space
				$WaterTop.visible = false;
				$WaterTop/Water.visible = false;
				
