extends KinematicBody2D

var momentum = Vector2.ZERO;
var is_crouching = false;
var is_aiming = false;
var current_reticle = null;
var can_aim_fire = false;

const MAX_SPEED = 120
const ACCEL = 6
const DECEL = 0.6
const CROUCH_DECEL = 0.2
const GRAVITY = 5

const JUMP_ACCEL = 200
const STANDSTILL = 20

const BOLT_EMITTER_OFFSET = Vector2(14, 0)

const FiringBolt = preload("res://FiringBolt.tscn")
const Reticle = preload("res://Reticle.tscn")

func _physics_process(delta):
	var move_vector = Vector2.ZERO
	is_crouching = false
	is_aiming = false
	
	if is_on_floor():
		if Input.is_action_pressed("crouch"):
			is_crouching = true
			set_collision_shape('crouch')
			if Input.is_action_pressed("fire"):
				aim()
		else:
			set_collision_shape('normal')
			if Input.is_action_pressed("jump"):
				jump()
				
			if Input.is_action_pressed("move_left"):
				move_vector += Vector2.LEFT
				
			if Input.is_action_pressed("move_right"):
				move_vector += Vector2.RIGHT
				
			if Input.is_action_just_pressed("fire"):
				fire_bolt()
	else:
		set_collision_shape('jump')
		move_vector.x = momentum.x
	
	calculate_momentum(move_vector)
	set_sprite()
	add_gravity()
	if !is_aiming:
		stop_aiming()
		
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
		momentum.x *= CROUCH_DECEL if is_crouching else DECEL

func set_sprite():
	if is_crouching:
		if Input.is_action_pressed("fire"):
			$AnimationPlayer.play("aim")
		else:
			$AnimationPlayer.play("crouch")
	elif !is_on_floor():
		$AnimationPlayer.play("jump")
	else:
		if momentum.x > STANDSTILL:
			$AnimationPlayer.play("run")
			$Sprite.flip_h = false
		elif momentum.x < -STANDSTILL:
			$AnimationPlayer.play("run")
			$Sprite.flip_h = true
		else:
			$AnimationPlayer.play("idle")
		
func add_gravity():
	momentum.y += GRAVITY
	
func set_collision_shape(shape):
	$NormalCollision.disabled = true
	$CrouchCollision.disabled = true
	$JumpCollision.disabled = true
	match shape:
		'crouch':
			$CrouchCollision.disabled = false
		'jump':
			$JumpCollision.disabled = false
		_:
			$NormalCollision.disabled = false

func fire_bolt():
	var dir = -1 if $Sprite.flip_h else 1
	var bolt = FiringBolt.instance()
	bolt.position = self.position + (BOLT_EMITTER_OFFSET * dir)
	bolt.direction = dir
	print(get_parent())
	get_parent().add_child(bolt)
	
func aim():
	is_aiming = true
	if current_reticle == null:
		current_reticle = Reticle.instance()
		current_reticle.position = find_aim_target()
		get_parent().add_child(current_reticle)
		current_reticle.connect("aim_completed", self, "aim_completed")

func find_aim_target():
	return get_parent().get_node("Target").position

func aim_completed():
	can_aim_fire = true
	
func stop_aiming():
	if current_reticle && is_instance_valid(current_reticle):
		current_reticle.queue_free()
		current_reticle = null
	can_aim_fire = false
