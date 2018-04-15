extends TextureRect

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
		
	if not 'result' in json or json.result == null:
		return
		
	if json.result[0].action == 'delete_lobby':
		get_tree().quit()

func _process(delta):
	# User presses "ESC" to quit game.
	if (Input.is_action_pressed("ui_cancel")):
		var QUERY = "a=delete_lobby&t="+global.auth_token
		print(QUERY)
		var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
		$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)
	
	# User presses "ENTER" to go back to lobby.
	elif (Input.is_action_pressed("ui_accept")):
		var QUERY = "a=delete_lobby&t="+global.auth_token
		print(QUERY)
		var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
		$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)

		get_tree().change_scene("res://LobbySearch.tscn")
