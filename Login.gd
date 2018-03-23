extends Node

onready var username = get_node("Panel/username/username_input")
onready var password = get_node("Panel/password/password_input")
onready var register = get_node("Panel/register_user/register_box")

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

	
func _on_HTTPRequest_request_completed( result, response_code, headers, body ):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	
	if json.result[0].status == 'Fail':
		return
		
	if json.result[0].action == 'login':
		return
		
	if json.result[0].action == 'register':
		# GOTO New Lobby
		return

func _on_LoginButton_pressed():
	var QUERY = "a=login&u="+username.get_text()+"&p="+password.get_text()+"&i=localhost"
		
	if register.is_pressed():
		QUERY = "a=register&u="+username.get_text()+"&p="+password.get_text()
		
	var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
	$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)

