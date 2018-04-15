extends Node

#Resizes the screen as soon as MainMenu node is ready

func _ready():
   var root = get_node("/root")
   root.connect("size_changed",self,"resize")
   set_process_input(true)

func resize():
	OS.set_window_size(Vector2(1050, 600))

#