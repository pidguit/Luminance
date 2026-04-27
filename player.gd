extends CharacterBody2D

# Variables Related to Jumping / Falling
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
var walljump = false
var walljumpoverride = false
var neutralwalljump = false

# Sliding Variables
var is_sliding = false
var slide_jump = false
const slide_duration = 0.25
var slide_timer = 0.25 # This counts backwards, don't change it lol
var slide_speed = 250
var slide_jump_speed = .85

var crouching = false
var aircrouch = false

var brightness = "light"
@onready var headlamp: PointLight2D = $DefaultHeadLamp
@onready var crouchingheadlamp: PointLight2D = $CrouchingHeadLamp
@onready var slidingheadlamp: PointLight2D = $SlidingHeadLamp

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
	
	# Resets double jump while on floor and animates walking and idle
	if is_on_floor():
		airjumpsavailable = MaxAirJumps
		slide_jump = false
		walljump = false
		walljumpoverride = false
		if velocity.x == 0:
			if brightness == "dark":
				$AnimatedSprite2D.play("IdleLight")
			else:
				$AnimatedSprite2D.play("Idle")
		elif is_sliding == false:
			if brightness == "dark":
				$AnimatedSprite2D.play("WalkingLight")
			else:
				$AnimatedSprite2D.play("Walking")
	
	# Starts a Slide
	if is_on_floor() and Input.is_action_just_pressed("slide") and is_sliding == false:
		start_slide()
	
	# Crouching Logic
	if is_sliding or slide_jump:
		crouching = false
		aircrouch = false
	elif is_on_floor() and Input.is_action_pressed("move_down"):
		crouching = true
	elif not is_on_floor() and Input.is_action_pressed("move_down"):
		aircrouch = true
		if airjumpsavailable < 1 or walljump or (velocity.y != 0 and (not crouching or not aircrouch)):
			crouching = false
			aircrouch = false
	elif can_stand_up() == false:
			crouching = true
			aircrouch = true
	else:
		crouching = false
		aircrouch = false
	
	# Counts down the sliding timer and ends slide
	if is_sliding == true:
		slide_timer -= delta # Starts timer
		if Input.is_action_just_pressed("jump"): # Cancels slide for a slide jump
			velocity.x *= slide_jump_speed
			slide_jump = true
			if not is_on_floor():
				MaxAirJumps += 1
			end_slide()
		if slide_timer <= 0: # Ends slide when timer is up
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
	
	# Can't move while crouching
	if crouching and is_on_floor():
		target_velocity_x = 0
	
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
		walljump = true
		
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
		velocity.x = move_toward(velocity.x, target_velocity_x, ACCELERATION * delta) # Walking Around (default)
	elif direction != 0 and sign(velocity.x) == sign(direction) and abs(velocity.x) > SPEED and walljumpoverride == false:
		pass # If flying air with higher than default speed, keeps it if moving in same direciton
	elif direction == 0 and abs(velocity.x) > SPEED and walljumpoverride == false:
		velocity.x = move_toward(velocity.x, target_velocity_x, (ACCELERATION/3) * delta) # decelerates if has too much speed and tries to go opposite direction
	else:
		velocity.x = move_toward(velocity.x, target_velocity_x, ACCELERATION * delta) # if you don't have too much speed, it goes back to default
	
	# Sliding down wall Physics
	if is_on_wall() and (not crouching or not aircrouch):
		var wall_dir = get_wall_normal().x
		if ((wall_dir > 0 and velocity.x < 0) or (wall_dir < 0 and velocity.x > 0)) and not is_on_floor():
			maxfallspeed = 50
			headlamp.position.x = -abs(headlamp.position.x)
			headlamp.scale.x = -1
			
		else:
			maxfallspeed = TERMINAL_VELOCITY
	
	# Flips sprite depending on horizontal velocity
	if (velocity.x > 1) or (crouching and direction > 0):
		$AnimatedSprite2D.flip_h = false
		headlamp.position.x = abs(headlamp.position.x)
		headlamp.scale.x = 1
		slidingheadlamp.position.x = abs(headlamp.position.x)
		slidingheadlamp.scale.x = 1
		crouchingheadlamp.position.x = abs(headlamp.position.x)
		crouchingheadlamp.scale.x = 1
		
	elif (velocity.x < -1) or (crouching and direction < 0):
		$AnimatedSprite2D.flip_h = true
		headlamp.position.x = -abs(headlamp.position.x)
		headlamp.scale.x = -1
		slidingheadlamp.position.x = -abs(headlamp.position.x)
		slidingheadlamp.scale.x = -1
		crouchingheadlamp.position.x = -abs(headlamp.position.x)
		crouchingheadlamp.scale.x = -1
	

	#print(position.x)
	animate(brightness)
	
	
	move_and_slide()

	# snaps character to pixels (don't really understand this still tbh)
	#$AnimatedSprite2D.position = position.snapped(Vector2(1,1)) - position

# Activates a slide
func start_slide():
	if brightness == "dark":
		$AnimatedSprite2D.play("SlideLight")
	else:
		$AnimatedSprite2D.play("Slide")
	is_sliding = true
	slide_timer = slide_duration
	var direction = last_direction
	velocity.x = slide_speed * direction
	
# Ends a slide
func end_slide():
	if brightness == "dark":
		$AnimatedSprite2D.play("WalkingLight")
	else:
		$AnimatedSprite2D.play("Walking")
	is_sliding = false
	set_collision("default")

# Sets collision based on what state is needed (can't do it in physics process)
func set_collision(state):
	$DefaultCollision.disabled = state != "default"
	$SlideCollision.disabled = state != "slide"
	$CrouchCollision.disabled = state != "crouch"
	if brightness == "light":
		headlamp.enabled = false
		slidingheadlamp.enabled = false
		crouchingheadlamp.enabled = false
	
	elif brightness == "dark":
		headlamp.enabled = (state == "default")
		slidingheadlamp.enabled = (state == "slide")
		crouchingheadlamp.enabled = (state == "crouch")
	
	
# Checks if the player can stand up (make sure player doesn't get stuck after a slide)
func can_stand_up():
	if $LeftRayCast.is_colliding() or $RightRayCast.is_colliding():
		return false
	else:
		return true

# Animation Logic for a couple states, allows for flipping it from light to dark
func animate(state):
	var list = []
	var dark = ["CrouchingLight", "MovingFallLight", "FallLight", "WallSlideLight"]
	var light = ["Crouching", "MovingFall", "Fall", "WallSlide"]
	
	if state == "dark":
		list = dark

	else:
		list = light
	
	if is_sliding:
		set_collision("slide")
	elif crouching or aircrouch or can_stand_up() == false:
		set_collision("crouch")
		$AnimatedSprite2D.play(list[0])
	elif not is_on_floor() and velocity.x != 0 and crouching == false and not is_on_wall():
		$AnimatedSprite2D.play(list[1])
	elif not is_on_floor() and not aircrouch and not is_on_wall():
		$AnimatedSprite2D.play(list[2])
	elif is_on_wall() and maxfallspeed == 50:
		$AnimatedSprite2D.play(list[3])
		headlamp.position.x = -headlamp.position.x
		headlamp.scale.x = -headlamp.scale.x

	else:
		set_collision("default")
		headlamp.position.x = (last_direction) * abs(headlamp.position.x)
		headlamp.scale.x = (last_direction) * abs(headlamp.scale.x)

# Put mouth on breathing animation?
