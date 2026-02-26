extends CharacterBody2D


const JUMP_VELOCITY = -210.0 # How fast and high character jumps
const TERMINAL_VELOCITY = 200 # Max fall speed

const SPEED = 95.0 # Sets max horizontal speed
const ACCELERATION = 1300.0 # How fast the character moves (x axis)
var MaxAirJumps = 1
var airjumpsavailable = 1

var last_direction = 1


func _physics_process(delta: float) -> void:
	# Add the gravity and set max fall speed
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y > TERMINAL_VELOCITY:
			velocity.y = TERMINAL_VELOCITY
	
	# Resets double jump while on floor
	if is_on_floor():
		airjumpsavailable = MaxAirJumps
		
	# Handles jump and double jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	elif Input.is_action_just_pressed("ui_accept") and airjumpsavailable > 0:
		velocity.y = JUMP_VELOCITY
		airjumpsavailable = airjumpsavailable - 1

	# Detects what direction the character should be moving including null movement
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
	
	# Sets target velocity and actually moves	
	var target_velocity_x = direction * SPEED
	velocity.x = move_toward(velocity.x, target_velocity_x, ACCELERATION * delta)
	
	# Flips sprite depending on horizontal velocity
	if velocity.x > 1:
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < -1:
		$AnimatedSprite2D.flip_h = true
		
	move_and_slide()
