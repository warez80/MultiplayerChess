extends Container

onready var startButton = get_node("startButton")
onready var behindStart = get_node("back")
onready var playerList = get_node("playerList")
onready var invitePlayerName = get_node("invitePlayerName")

var is_server = false

func _ready():
	get_tree().set_auto_accept_quit(false)
	
	startButton.icon = load("res://Start_button.png")
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
	is_server = global.my_role == global.PlayerRole.SERVER
	
	playerList.text = ""
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

func _on_startButton_pressed():
	global.host_start_game()

func _on_invitePlayerButton_pressed():
	var QUERY = "a=send_request&t="+global.auth_token+"&h="+global.my_local_ip+"&i="+invitePlayerName.get_text()
	print(QUERY)
	var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
	$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)
