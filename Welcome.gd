extends TextureRect

var main_menu = "the_main_menu_"
var repeat = 0
var end = 10
var glitching = false
var exiting = false

func _ready():
	self.texture = load("res://"+main_menu+str(1)+".png")	
	
func _glitch_screen(i):
	var num = i
	self.texture = load("res://glitch_"+str(num)+".png")

func _process(delta):
	# This function will contain a lot of visual effects, to emulate
	# 'blue screen of death' and glitching 
	
	# if end is true, then glitch the screen 'repeat' number of times
	if(glitching):
		_glitch_screen(randi() % 14)
		
		repeat = repeat + 1
		
		#once we've glitched 'repeat' number of times, exit the scene
		if(repeat >= end):
			exiting = true
	# 
	if(exiting):
		# change scene to login screen
		get_tree().change_scene("res://Login.tscn")
		
	# if ESC is pressed, quit the game
	if(Input.is_action_pressed("ui_cancel") and not glitching):
		get_tree().quit()
	# if ENTER is pressed, start the glitting
	elif(Input.is_action_pressed("ui_accept") and not glitching):
		# let the glitching commence
		glitching = true
		
		