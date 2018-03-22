extends CanvasLayer

onready var serverBrowser = get_node("ServerListWrapper")
onready var lobbyName = get_node("Input_LobbyName")

var token = "7B1B16A4-A583-4236-A9E1-592F75BC2F40"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result[0].action == 'lobby_search':
		_update_Server_Browser(json.result[0].result)

# Updates the server browser list
func _update_Server_Browser(json):
	print("Lobbies:")
	for entry in json:
		print(entry)
		print("---")
		
		var wrapper = VBoxContainer.new()
		wrapper.rect_min_size = Vector2(10, 50)
		serverBrowser.add_child(wrapper)

		
		var title = Label.new()
		title.set_text(entry['lobby_name'])
		wrapper.add_child(title)
		
		var host = Label.new()
		host.set_text(entry['host_name'])
		wrapper.add_child(host)


func _on_Search_pressed():
	var QUERY = "a=lobby_search&t="+token+"&n="+lobbyName.get_text()
	var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
	$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)
