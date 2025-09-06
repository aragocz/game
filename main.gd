extends Node


func _process(_delta:float):
	#DEBUG FUNCTION
	if Input.is_action_just_pressed("menu"):
		get_tree().quit()
