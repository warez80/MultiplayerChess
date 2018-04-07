extends CanvasLayer

onready var serverBrowser = get_node("ServerListWrapper/ServerList")
onready var lobbyName = get_node("Input_LobbyName")
onready var createLobbyName = get_node("VBoxContainer/GridContainer/Input_Create_LobbyName")
onready var createLobbyPassword = get_node("VBoxContainer/GridContainer/Input_Create_LobbyPassword")

var token = "512F6954-6E14-4DAF-8816-99F3FAE46C46"
var userIP = "localhost"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	_on_Search_pressed()	# Populate with default
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	
	if json.result[0].status == 'Fail':
		return
		
	if json.result[0].action == 'lobby_search':
		_update_Server_Browser(json.result[0].result)
		
	if json.result[0].action == 'create_lobby':
		# GOTO New Lobby
		return

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
		join.set_text("Join")
		buttonWrapper.add_child(join)
		join.connect("pressed", self, "_on_LobbyJoin_pressed", [entry['host_ip']])

# User pressed search button
func _on_Search_pressed():
	var QUERY = "a=lobby_search&t="+token+"&n="+lobbyName.get_text()
	var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
	$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)

# User creates lobby
func _on_LobbyCreate_pressed():
	var QUERY = "a=create_lobby&t="+token+"&n="+createLobbyName.get_text()+"&p="+createLobbyPassword.get_text()+"&i="+userIP
	print(QUERY)
	var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
	$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)

#Lobby Join
func _on_LobbyJoin_pressed(ip):
	print("Join Lobby with IP: " + ip)
	