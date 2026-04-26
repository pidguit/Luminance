extends Camera2D
var player : Node2D

var left_limit = -46
var right_limit = 300
var default_y = -70

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("../Player")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var target_pos = player.global_position
	
	target_pos.x = clamp(target_pos.x, left_limit, right_limit)
	
	var desired_y = default_y
	
	if player.global_position.y < -108:
		desired_y = default_y - 60
		
	
	target_pos.y = lerp(global_position.y, float(desired_y), 0.03)
	
	global_position = target_pos
	#print(player.position)
	
