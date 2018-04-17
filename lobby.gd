extends Container

onready var startButton = get_node("startButton")
onready var behindStart = get_node("back")
onready var playerList = get_node("playerList")
onready var invitePlayerName = get_node("invitePlayerName")
onready var music = get_node("Wait_Music")
var playing = false
var song_position = 0

var is_server = false

func _ready():
	get_tree().set_auto_accept_quit(false)

	startButton.icon = load("res://Start_button.png")

	# Need some nice music for the lobby
	var song = load("lobby_music.ogg")
	music.set_stream(song)
	music.play()
	playing = true

	# Only host can start game
	if global.my_role != global.PlayerRole.SERVER:
		behindStart.hide()
		startButton.hide()

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)

	if not 'result' in json or json.result == null:
		return

	if json.result[0].action == 'delete_lobby':
		get_tree().quit()

func _notification(what):
	if is_server and what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		var QUERY = "a=delete_lobby&t="+global.auth_token
		print(QUERY)
		var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
		$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)
	elif what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit()

func _process(delta):

	if (Input.is_action_pressed("ui_cancel")):
		get_tree().change_scene("res://LobbySearch.tscn")


	is_server = global.my_role == global.PlayerRole.SERVER

	playerList.text = ""

	if (Input.is_action_pressed("ui_select")):
		if (playing):
			playing = false
			song_position = music.get_playback_position()
			music.stop()
		else:
			playing = true
			music.play(song_position)
	
	for id in global.player_info:
		var player = global.player_info[id]
		var role = ""
		if player.role == global.PlayerRole.CLIENT:
			role = "Player"
		if player.role == global.PlayerRole.SERVER:
			role = "Host"
		if player.role == global.PlayerRole.SPECTATOR:
			role = "Spectator"

		playerList.add_text(player.username + " (" + role + ")\n")

	$Chat_Box/BetterChat.text = ""
	for msg in global.chat_messages:
		$Chat_Box/BetterChat.add_text(msg + "\n")

func _on_startButton_pressed():
	global.host_start_game()

func _on_invitePlayerButton_pressed():
	var QUERY = "a=send_request&t="+global.auth_token+"&h="+global.my_local_ip+"&i="+invitePlayerName.get_text()
	print(QUERY)
	var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
	$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)


func _on_SendChatButton_pressed():
	global.send_chat_to_server($Text_Input/ChatInputBox.text)
	$Text_Input/ChatInputBox.text = ""
