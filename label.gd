extends Label

var camera : Camera2D
var player : Node2D
var playerposition = 0
var stuck = false

var y_axis = -155
var labeltext = [
	"Welcome to Luminance!
	you can walk with A + D or Arrow keys",
	"You can Jump with Space or C",
	"To Double Jump, Jump while in mid-air!",
	"You can Slide with Shift or X",
	"To Wall Jump, Jump While sliding down a wall",
	"You can Slide Jump to get a speed boost!
	To do so start a Slide and Jump right after",
	"If you get stuck after a Slide, you can either
	Slide again or Crouch Jump out of the area",
	"Nice! Walk to the right to start the next level"
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = get_node("../Camera2D")
	player = get_node("../Player")
	pass # Replace with function body.
	textchange(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_pos = camera.global_position.round()
	playerposition = player.position.x
	if not player.can_stand_up() and player.crouching == true:
		stuck = true
	else:
		stuck = false
	
	target_pos.x = target_pos.x-142.5 # Centers it to the camera
	target_pos.y = y_axis
	global_position = target_pos
	
	# Big if chain to change the dialog of the tutorial lol (can't be bothered to make it look nice)
	if playerposition >= -70 and playerposition <= 0:
		textchange(1)
	if playerposition >= 0 and playerposition <= 216:
		textchange(2)
	if playerposition >= 126 and playerposition <= 206:
		textchange(3)
	if playerposition >= 206 and playerposition <= 293:
		textchange(4)
	if playerposition >= 293 and not stuck and player.is_sliding == false and player.can_stand_up() == true and playerposition <= 451:
		textchange(5)
	if stuck:
		textchange(6)
	if playerposition >= 451:
		textchange(7)
	#print(playerposition)

	pass
	# Note that the end of the level is when the player enters 518+
func textchange(number):
	text = labeltext[number]
	
	
