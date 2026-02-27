extends CharacterBody2D


const JUMP_VELOCITY = -210.0 # How fast and high character jumps
const TERMINAL_VELOCITY = 200 # Max fall speed
var maxfallspeed = 200

const SPEED = 95.0 # Sets max horizontal speed
const ACCELERATION = 900.0 # How fast the character moves (x axis)
var MaxAirJumps = 1
var airjumpsavailable = 1

var last_direction = 1

const WallSlideSpeed = 100
const WALLJUMP_FRAMES = 10
var walljumptimer = 0
var walldirection = 0
var walljumpoverride = false
var neutralwalljump = false


func _physics_process(delta: float) -> void:
	# direction the player is facing (put at top just in case for later)
	var direction = 0
	
	# Add the gravity and set max fall speed
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not is_on_wall():
			maxfallspeed = TERMINAL_VELOCITY
		if velocity.y > maxfallspeed:
			velocity.y = maxfallspeed
	
	# Resets double jump while on floor
	if is_on_floor():
		airjumpsavailable = MaxAirJumps
		walljumpoverride = false
		
	# Handles jump and double jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	elif Input.is_action_just_pressed("ui_accept") and airjumpsavailable > 0 and not is_on_wall():
		velocity.y = JUMP_VELOCITY
		airjumpsavailable -= 1
		walljumpoverride = false
		walljumptimer = 0

	# Detects what direction the character should be moving including null movement
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
		
	# Walking target velocity
	var target_velocity_x = direction * SPEED

	# Handles Wall Jump
	if not is_on_floor() and is_on_wall():
		if Input.is_action_just_pressed("ui_accept"):
			walljumptimer = 0
			velocity.y = JUMP_VELOCITY
			walljumpoverride = true
			neutralwalljump = false
			if walljumptimer < 2 and direction == 0:
				neutralwalljump	= true

	# Get's wall direction
	if is_on_wall():
		walldirection = get_wall_normal().x

	# Changes target velocity for wall jumps
	if walljumpoverride == true and walljumptimer != WALLJUMP_FRAMES:
		walljumptimer += 1
		if neutralwalljump == true:
			target_velocity_x = walldirection * SPEED
		else:
			target_velocity_x = walldirection * SPEED + (40 * walldirection)

	if walljumptimer == WALLJUMP_FRAMES:
		if neutralwalljump == true:
			if walljumptimer ==  15:
				walljumptimer = 0
		else:
			walljumptimer = 0
			walljumpoverride = false
			neutralwalljump = false

	# This actually moves the character (moves towards target velocity with acceleration)
	velocity.x = move_toward(velocity.x, target_velocity_x, ACCELERATION * delta)
	
	if is_on_wall():
		var wall_dir = get_wall_normal().x
		if (wall_dir > 0 and direction < 0) or (wall_dir < 0 and direction > 0):
			maxfallspeed = 50
		else:
			maxfallspeed = TERMINAL_VELOCITY
	
	# Flips sprite depending on horizontal velocity
	if velocity.x > 1:
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < -1:
		$AnimatedSprite2D.flip_h = true
		
			# Wall Jump Detection
			
	move_and_slide()
	# snaps character to pixels?	
	#$AnimatedSprite2D.position = position.snapped(Vector2(1,1)) - position
