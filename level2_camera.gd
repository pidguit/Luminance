extends Camera2D
var player : Node2D

var left_limit = -46
var right_limit = 350
const default_y = -70

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("../Player")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	var target_pos = player.global_position
	var desired_y = default_y
	
	if player.global_position.y < -215:
		desired_y = default_y - 225
		left_limit = -225
		right_limit = 100
	elif player.global_position.y < -108:
		desired_y = default_y - 100
		right_limit = 50
		left_limit = -225
	else:
		right_limit = 50
		left_limit = -60
		desired_y = default_y
	
	target_pos.y = lerp(global_position.y, float(desired_y), 0.03)
	target_pos.x = clamp(target_pos.x, left_limit, right_limit)
	
	global_position = target_pos
	
	#print(desired_y)
	
