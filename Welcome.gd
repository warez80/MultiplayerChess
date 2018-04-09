extends TextureRect

var main_menu = "the_main_menu_"
var repeat = 0
var end = 10
var glitch = false
var exit = false


func _ready():
	self.texture = load("res://"+main_menu+str(1)+".png")	
	

func _glitch_screen(i):
	var num = i
	self.texture = load("res://glitch_"+str(num)+".png")

func _process(delta):
	
	# if end is true, then glitch screen 
	if(glitch):
		repeat = repeat + 1
		_glitch_screen(randi() % 14)
		if(repeat >= end):
			exit = true
			
	if(exit):
		get_tree().change_scene("res://Login.tscn")
		
	if(Input.is_action_pressed("ui_cancel")):
		get_tree().quit()
	elif(Input.is_action_pressed("ui_accept")):
		# let the glitching commence
		glitch = true
		