extends Camera2D
var player : Node2D

const LEFT_LIMIT = -46
const RIGHT_LIMIT = 300
const FIXED_Y = -70

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("../Player")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var target_pos = player.global_position

	target_pos.x = clamp(target_pos.x, LEFT_LIMIT, RIGHT_LIMIT)
	target_pos.y = FIXED_Y

	global_position = target_pos
