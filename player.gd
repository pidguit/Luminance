extends CharacterBody2D

#  Variables Related to Jumping / Falling
const JUMP_VELOCITY = -210.0 # How fast and high character jumps
const TERMINAL_VELOCITY = 200 # Max fall speed
var maxfallspeed = 200
var MaxAirJumps = 1
var airjumpsavailable = 1

# Walking Variables
const SPEED = 95.0 # Sets max horizontal speed
const ACCELERATION = 900.0 # How fast the character moves (x axis)
var last_direction = 1

# Wall Jumping Variables
const WallSlideSpeed = SPEED
const WallJumpDuration = .15
const NeutralWallJumpDuration = .10
const WallJumpSpeed = 150
const NeutralWallJumpSpeed = 100
var walljumptimer = 0
var walldirection = 0
var walljumpoverride = false
var neutralwalljump = false

# Sliding Variables
var is_sliding = false
const slide_duration = 0.25
var slide_timer = 0.25 # This counts backwards, don't change it lol
var slide_speed = 250
var slide_jump_speed = .85

func _physics_process(delta: float) -> void:
	# direction the player is facing (put at top just in case for later cause there's a lot of things that use this)
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
	
	if is_on_floor() and Input.is_action_just_pressed("slide") and is_sliding == false:
		start_slide()
		
	if is_sliding == true:
		slide_timer -= delta
		if Input.is_action_just_pressed("jump"):
			velocity.x *= slide_jump_speed
			end_slide()
	
	if slide_duration <= 0:
		end_slide()
		
	# Handles jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handles Double Jump
	elif Input.is_action_just_pressed("jump") and airjumpsavailable > 0 and not is_on_wall():
		velocity.y = JUMP_VELOCITY
		airjumpsavailable -= 1
		walljumpoverride = false
		walljumptimer = 0

	# Detects what direction the character should be moving including null movement
	var left_pressed = Input.is_action_pressed("move_left")
	var right_pressed = Input.is_action_pressed("move_right")
	
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
		
	# Walking target velocity, this is the default
	var target_velocity_x = direction * SPEED
	
	# Get's wall direction (for wall jump)
	if is_on_wall():
		walldirection = get_wall_normal().x
		
	# Activates a Wall Jump
	if not is_on_floor() and is_on_wall() and Input.is_action_just_pressed("jump"):
		walljumptimer = 0
		walljumpoverride = true
		velocity.y = JUMP_VELOCITY
		if direction == 0:
			neutralwalljump = true
		else:
			neutralwalljump = false

	# Adds the velocity for wall jumps
	if walljumpoverride == true:
		walljumptimer += delta
		
		if neutralwalljump == true:
			velocity.x = (NeutralWallJumpSpeed * walldirection)
		else:
			velocity.x = (WallJumpSpeed * walldirection)

		if walljumptimer >= WallJumpDuration and neutralwalljump == false:
			walljumpoverride = false
			walljumptimer = 0
		
		if walljumptimer >= NeutralWallJumpDuration and neutralwalljump == true:
			walljumpoverride = false
			neutralwalljump = false
			walljumptimer = 0

	# This actually moves the character (moves towards target velocity with acceleration)
	if is_on_floor():
		velocity.x = move_toward(velocity.x, target_velocity_x, ACCELERATION * delta) # Walking  Around (default)
	elif direction != 0 and sign(velocity.x) == sign(direction) and abs(velocity.x) > SPEED and walljumpoverride == false:
		pass # If flying air with higher than default speed, keeps it if moving in same direciton
	elif direction == 0 and abs(velocity.x) > SPEED and walljumpoverride == false:
		velocity.x = move_toward(velocity.x, target_velocity_x, (ACCELERATION/3) * delta) # decelerates if has too much speed and tries to go opposite direction
	else:
		velocity.x = move_toward(velocity.x, target_velocity_x, (ACCELERATION) * delta) # if you don't have too much speed, it goes back to default
	
	# Sliding down wall Physics
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

	move_and_slide()
	# snaps character to pixels (don't  really understand this still tbh)
	$AnimatedSprite2D.position = position.snapped(Vector2(1,1)) - position

# Activates a slide
func start_slide():
	rotation_degrees = -90 * last_direction
	is_sliding = true
	slide_timer = slide_duration
	var direction = last_direction
	velocity.x = slide_speed * direction
	
# Ends a slide
func end_slide():
	is_sliding = false
	rotation_degrees = 0
	airjumpsavailable += 1 # Just because I'm temporarly rotating the model, when jump cancels a slide, it uses double jump so giving it back
