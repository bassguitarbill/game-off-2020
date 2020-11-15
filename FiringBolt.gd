extends KinematicBody2D

var direction = 1
const velocity = Vector2.RIGHT * 800

func _physics_process(delta):
	move_and_collide(velocity * delta * direction)
	
func _ready():
	$AnimationPlayer.playback_speed = 2
	$AnimationPlayer.play("fire")
	if direction == -1:
		$Sprite.flip_h = true

func _on_AnimationPlayer_animation_finished(anim_name):
	$Sprite.visible = false
	queue_free()
