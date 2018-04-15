extends TextureRect

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	if (Input.is_action_pressed("ui_cancel")):
		get_tree().quit()
	elif (Input.is_action_pressed("ui_accept")):
		get_tree().change_scene("res://LobbySearch.tscn")
