extends Node2D

signal aim_completed

func _ready():
	$AnimationPlayer.play("aim")
	
func _on_AnimationPlayer_animation_finished(anim_name):
	$aiming.visible = false
	$AnimationPlayer.play("aiming")
	emit_signal("aim_completed")
