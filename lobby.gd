extends Container

onready var startButton = get_node("startButton")
onready var behindStart = get_node("back")
onready var playerList = get_node("playerList")
onready var invitePlayerName = get_node("invitePlayerName")

func _ready():
	
	startButton.icon = load("res://Start_button.png")
	# Only host can start game
	if global.my_role != global.PlayerRole.SERVER:
		behindStart.hide()
		startButton.hide()

func _process(delta):
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
