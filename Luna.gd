extends KinematicBody2D

var momentum = Vector2.ZERO;

const MAX_SPEED = 120
const ACCEL = 6
const DECEL = 0.6
const GRAVITY = 5

const JUMP_ACCEL = 200
const STANDSTILL = 20

func _physics_process(delta):
	var move_vector = Vector2.ZERO
	if Input.is_action_pressed("crouch"):
		$Sprite.visible = false
		$CrouchSprite.visible = true
	else:
		$Sprite.visible = true
		$CrouchSprite.visible = false
		
	if Input.is_action_just_pressed("jump") && is_on_floor():
		jump()
	
	if Input.is_action_pressed("move_left"):
		move_vector += Vector2.LEFT
		
	if Input.is_action_pressed("move_right"):
		move_vector += Vector2.RIGHT
	
	calculate_momentum(move_vector)
	set_sprite()
	add_gravity()
	momentum = move_and_slide(momentum, Vector2.UP);
	
func jump():
	momentum.y -= JUMP_ACCEL

func calculate_momentum(move_vector):
	momentum += (move_vector * ACCEL)
	if momentum.x >= MAX_SPEED:
		momentum.x = MAX_SPEED
	elif momentum.x <= -MAX_SPEED:
		momentum.x = -MAX_SPEED
	
	if move_vector.x == 0:
		momentum.x *= DECEL

func set_sprite():
	if momentum.x > STANDSTILL:
		$AnimationPlayer.play("run")
		$Sprite.flip_h = false
		$CrouchSprite.flip_h = false
	elif momentum.x < -STANDSTILL:
		$AnimationPlayer.play("run")
		$Sprite.flip_h = true
		$CrouchSprite.flip_h = true
	else:
		$AnimationPlayer.play("idle")
		
func add_gravity():
	momentum.y += GRAVITY
