extends Container

onready var serverBrowser = get_node("ServerListWrapper/ServerList")
onready var lobbyName = get_node("Input_LobbyName")
onready var createLobbyName = get_node("Input_Create_LobbyName")
onready var createLobbyPassword = get_node("Input_Create_LobbyPassword")
onready var player = get_node("Vaporwave_Player")
onready var desktop = get_node("background")
onready var timer = get_node("Timer")
onready var accept_dialog = get_node("AcceptDialog")
onready var search_button = get_node("Button")
onready var create_button = get_node("Button2")

var songNames = ["boot", "ECCO_and_chill_diving", "Flower_specialty_store", "geography", "importance", "LisaFrank_420_Modern_Computing", "mathematics", "The", "Untitled_1", "Untitled_2", "Wait"]
var song_playing = true
var song_position = 0
var song_number = 4
var elapsed_time = 0

var request_host_ip = ""

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
		
	if Input.is_action_just_pressed("ui_right"):
		song_number = song_number + 1 
		if song_number < 0 :
			song_number = len(songNames) - 1
		var current_song = load(songNames[song_number] + ".ogg")
		player.set_stream(current_song)

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
	global.connect(ip)
	get_tree().change_scene("res://lobby.tcsn")
	
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
