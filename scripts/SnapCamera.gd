@tool
extends Camera2D

@export var focusNode:NodePath
@export var snapRounded = 1 # if you don't like the camera being halfway between tiles, I reccomend 8, 16 and 32 or whatever your cell size is, don't do 0
var nodePoint = null
var nodeRef
var screenSize = Vector2(600,800)

func _ready():
	# get the screen size
	screenSize = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height"))
	# check that the object being focussed is assigned
	if (focusNode != null):
		# check that the node still exists
		nodePoint = get_node(focusNode)
		nodeRef = weakref(nodePoint)
		snap_camera(nodePoint.position)
	# if we're the currently active camera then set global camera to this camera
	if !Engine.is_editor_hint():
		if enabled:
			Global.currentCamera = self

func _process(_delta):
	if Engine.is_editor_hint():
		# snap camera to mouse
		var mouse = get_global_mouse_position()
		snap_camera(mouse)
	else:
		# snap the camera to the focus node
		if (nodeRef.get_ref()):
			global_position = nodePoint.global_position
			if (!Global.cameraLock):
				snap_camera(nodePoint.position)

func snap_camera(getPosition = Vector2.ZERO):
	# set the camera border limits based on the targets position
	limit_left = ceil((floor(getPosition.x/screenSize.x)*screenSize.x)/snapRounded)*snapRounded
	limit_right = limit_left+screenSize.x
	limit_top = ceil((floor(getPosition.y/screenSize.y)*screenSize.y)/snapRounded)*snapRounded
	limit_bottom = limit_top+screenSize.y
