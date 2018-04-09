extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

#Resizes the screen as soon as MainMenu node is ready

func _ready():
   var root = get_node("/root")
   root.connect("size_changed",self,"resize")
   set_process_input(true)

func resize():
	OS.set_window_size(Vector2(1050, 600))

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
