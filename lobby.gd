extends Container

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var startButton = get_node("startButton")
onready var playerList = get_node("playerList")
onready var invitePlayerName = get_node("invitePlayerName")

func _ready():
	
	# Only host can start game
	if global.my_role != global.PlayerRole.SERVER:
		startButton.hide()
		
	# Called every time the node is added to the scene.
	# Initialization here
	pass

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
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_startButton_pressed():
	global.host_start_game()


func _on_invitePlayerButton_pressed():
	var QUERY = "a=send_request&t="+global.auth_token+"&h="+global.my_local_ip+"&i="+invitePlayerName.get_text()
	print(QUERY)
	var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
	$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)

