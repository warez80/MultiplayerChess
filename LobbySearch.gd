extends Container

onready var serverBrowser = get_node("ServerListWrapper/ServerList")
onready var list = get_node("ServerListWrapper")
onready var lobbyName = get_node("Input_LobbyName")
onready var createLobbyName = get_node("Input_Create_LobbyName")
onready var createLobbyPassword = get_node("Input_Create_LobbyPassword")
onready var player = get_node("Vaporwave_Player")
onready var desktop = get_node("background")
onready var timer = get_node("Timer")
onready var accept_dialog = get_node("AcceptDialog")
onready var search_button = get_node("Button")
onready var create_button = get_node("Button2")

# Music stuff
var songNames = ["boot", "ECCO_and_chill_diving", "Flower_specialty_store", "geography", "importance", "LisaFrank_420_Modern_Computing", "mathematics", "The", "Untitled_1", "Untitled_2", "Wait"]
var song_playing = true
var song_position = 0
var song_number = 5
var elapsed_time = 0

# Anim. Stuff
onready var welc_img = get_node("server_browser")
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

var request_host_ip = ""
var IP = ""

func _ready():
	
	search_button.icon = load("res://search.png")
	create_button.icon = load("res://create.png")
	timer.start()
	accept_dialog.add_cancel("Decline")
	
	var current_song = load(songNames[song_number] + ".ogg")
	player.set_stream(current_song)
	
	if song_playing:
		player.play()
	
		
	_on_Search_pressed()


func _process(delta):
	
	# if they want to pause the song
	if Input.is_action_pressed("ui_select"):
		if song_playing:
			song_playing = false
			song_position = player.get_playback_position()
			player.stop()
		else:
			song_playing = true
			player.play(song_position)

	# if they want to play a different song
	if Input.is_action_just_pressed("ui_left"):
		song_number = song_number - 1
		if song_number >= len(songNames):
			song_number = 0
			
		var current_song = load(songNames[song_number] + ".ogg")
		player.set_stream(current_song)
		player.play()
		
	if Input.is_action_just_pressed("ui_right"):
		song_number = song_number + 1 
		if song_number < 0 :
			song_number = len(songNames) - 1
		var current_song = load(songNames[song_number] + ".ogg")
		player.set_stream(current_song)
		player.play()
	
	# Animation Stuff
	time_passed += delta
	
	if((shrink or grow) and (time_passed >= time_for_one_call)):
		_exit_animation()
		time_passed -= time_for_one_call
		
	if(welc_img.scale.x <= 0 or welc_img.scale.y <= 0):
		shrink = false
		grow = true
	
	if(welc_img.scale.x >= 10 or welc_img.scale.y >= 10):
		background.texture = load("res://vpbk_login_6.jpg")
		welc_img.texture = load("res://lobby_pic.png")
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
	serverBrowser.hide()
	createLobbyName.hide()
	createLobbyPassword.hide()
	search_button.hide()
	create_button.hide()
	list.hide()
	if(shrink):
		DX = 0.2
		welc_img.scale.x -= DX
		welc_img.scale.y -= DX
		if(welc_img.scale.x <= 1 and welc_img.scale.y <= 1):
			#finally ready to transition
			if(change):
				global.connect(IP)
				get_tree().change_scene("res://lobby.tscn")
	
	if(grow):
		DX = 0.3
		welc_img.scale.x += DX
		welc_img.scale.y += DX
	

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
		
	if not 'result' in json or json.result == null:
		return
	
	if json.result[0].status == 'Fail':
		return
		
	print(json.result[0].action)
		
	if json.result[0].action == 'lobby_search':
		_update_Server_Browser(json.result[0].result)
		
	if json.result[0].action == 'create_lobby':
		global.setup_game("127.0.0.1")
		get_tree().change_scene("res://lobby.tscn")
	
	# Bunch-o-cases to prevent erros
	if json.result[0].action == 'get_requests' and len(json.result) > 0 and len(json.result[0].result) > 0:
		_alert_request(json.result[0].result)
		
#Pops up a request
func _alert_request(json):
	accept_dialog.dialog_text = json[0]['request_name'] + " has invited you to a game. Would you like to join?"
	request_host_ip = json[0].host_ip
	accept_dialog.popup()

# Updates the server browser list
func _update_Server_Browser(json):
	
	for i in serverBrowser.get_children():
		i.queue_free()
		
	print("Lobbies:")
	for entry in json:
		print(entry)
		print("---")
		
		var wrapper = VBoxContainer.new()
		wrapper.connect("timeout", self, "on_timer_timeout")
		serverBrowser.add_child(wrapper)
		
		var title = Label.new()
		title.set_text(entry['lobby_name'])
		wrapper.add_child(title)
		
		var host = Label.new()
		host.set_text(entry['host_name'])
		wrapper.add_child(host)
		
		var buttonWrapper = HBoxContainer.new()
		wrapper.add_child(buttonWrapper)
		
		var join = Button.new()
		join.icon = load("res://join.png")
		join.set_scale(Vector2(0.1, 0.1))
		buttonWrapper.add_child(join)
		
		join.connect("pressed", self, "_on_LobbyJoin_pressed", [entry['host_ip']])

# User pressed search button
func _on_Search_pressed():
	var QUERY = "a=lobby_search&t="+global.auth_token+"&n="+lobbyName.get_text()
	var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
	$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)

#Lobby Join
func _on_LobbyJoin_pressed(ip):
	print("Join Lobby with IP: " + ip)
	shrink = true
	IP = ip
	
func timeout():
	print("time_out")
	
func _on_AcceptDialog_confirmed():
	_on_LobbyJoin_pressed(request_host_ip)

func _on_Timer_timeout():
	var QUERY = "a=get_requests&t="+global.auth_token
	print(QUERY)
	var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
	$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)
	timer.set_wait_time(5)
	timer.start()


func _on_createLobby_pressed():
	var QUERY = "a=create_lobby&t="+global.auth_token+"&n="+createLobbyName.get_text()+"&p="+createLobbyPassword.get_text()+"&i="+global.my_local_ip
	print(QUERY)
	var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
	$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)
