extends CharacterBody2D


const JUMP_VELOCITY = -210.0
const TERMINAL_VELOCITY = 200

const SPEED = 95.0
const ACCELERATION = 1300.0       # How fast the character accelerates
const DECELERATION = 800.0       # How fast the character slows down

var MaxAirJumps = 1
var airjumpsavailable = 1

var last_direction = 1


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y > TERMINAL_VELOCITY:
			velocity.y = TERMINAL_VELOCITY
		
	if is_on_floor():
		airjumpsavailable = MaxAirJumps
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	elif Input.is_action_just_pressed("ui_accept") and airjumpsavailable > 0:
		velocity.y = JUMP_VELOCITY
		airjumpsavailable = airjumpsavailable - 1
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = 0
	var left_pressed = Input.is_action_pressed("ui_left")
	var right_pressed = Input.is_action_pressed("ui_right")

	if left_pressed and not right_pressed:
		direction = -1
		last_direction = -1
	elif right_pressed and not left_pressed:
		direction = 1
		last_direction = 1
	elif left_pressed and right_pressed:
		direction = -last_direction
	else:
		direction = 0
	
	# Now that direction is set, calculate target velocity
	var target_velocity_x = direction * SPEED

	# Smooth movement
	velocity.x = move_toward(velocity.x, target_velocity_x, ACCELERATION * delta)

	move_and_slide()
