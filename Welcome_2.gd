extends Container
onready var welc_img = get_node("welcome_img")
onready var background = get_node("background")
var shrink = false
var grow = false
var change = false
var X = 1
var Y = 1
var DX = 0.1
var time_passed = 0
var calls_per_sec = 3
var time_for_one_call = 1 / calls_per_sec

func _ready():
	pass

func _process(delta):
	
	time_passed += delta
	
	if((shrink or grow) and (time_passed >= time_for_one_call)):
		_exit_animation()
		time_passed -= time_for_one_call
		
	if(welc_img.scale.x <= 0 or welc_img.scale.y <= 0):
		shrink = false
		grow = true
	
	if(welc_img.scale.x >= 10 or welc_img.scale.y >= 10):
		background.texture = load("res://vpbk_login_0.jpg")
		welc_img.texture = load("res://server_browser.png")
		grow = false
		shrink = true
		change = true
	
	# if ESC is pressed, quit the game
	if(Input.is_action_pressed("ui_cancel")):
		get_tree().quit()
	# if ENTER is pressed, start the glitting
	elif(grow == false and Input.is_action_pressed("ui_accept")):
		#run the video to lobbysearch anim
		#then change scene
		shrink = true
		
	
func _exit_animation():
	
	if(shrink):
		DX = 0.2
		welc_img.scale.x -= DX
		welc_img.scale.y -= DX
		if(welc_img.scale.x <= 1 and welc_img.scale.y <= 1):
			#finally ready to transition
			if(change):
				get_tree().change_scene("res://LobbySearch.tscn")
	
	if(grow):
		DX = 0.3
		welc_img.scale.x += DX
		welc_img.scale.y += DX
	
	#get_tree().change_scene("res://LobbySearch.tscn")