extends Node2D

func _input(event):
	if(event.as_text() == 'L'):
		print_tree()
