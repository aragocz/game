extends Node
var tmp = Sprite2D.new()

func _ready() -> void:
	tmp.texture = load("res://icon.svg")
	tmp.scale = Vector2(0.1,0.1);
	self.add_child(tmp)

func _process(_delta:float):
	#DEBUG FUNCTION
	if Input.is_action_just_pressed("menu"):
		get_tree().quit()

func _physics_process(_delta: float) -> void:
	tmp.global_position = DisplayServer.mouse_get_position();
	print(DisplayServer.mouse_get_position())
	print(get_viewport().get_mouse_position())
	print(get_viewport().get_camera_2d().get_global_mouse_position())
	print("####")
