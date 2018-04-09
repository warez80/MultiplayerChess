extends Node

onready var username = get_node("Panel/username/username_input")
onready var password = get_node("Panel/password/password_input")
onready var register = get_node("Panel/register_user/register_box")
onready var error = get_node("error_text")
onready var login = get_node("Panel/login/login_button")

var errorCount = 0

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	error.set_text("")
	pass

func _on_HTTPRequest_request_completed( result, response_code, headers, body ):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)

	if errorCount > 4:
		login.disabled = true
		error.set_text("Too many incorrect login attempts. Please try again in 5 minutes")
		return

	if json.result[0].status == 'Fail':
		error.set_text("Error: " + json.result[0].reason)
		errorCount += 1;
		return

	# Login sucess, go to server browser
	if json.result[0].action == 'login':
		global.auth_token = json.result[0].auth_token
		get_tree().change_scene("res://LobbySearch.tscn")
		return

	# If registration is success, log user in
	if json.result[0].action == 'register':
		register.pressed = false
		_on_LoginButton_pressed()
		return

func _on_LoginButton_pressed():
	if username.get_text().length() < 1 or password.get_text().length() < 1:
		error.set_text("Error: Missing Username or Password")
		return
		
	var QUERY = "a=login&u="+username.get_text()+"&p="+password.get_text()+"&i=localhost"

	if register.is_pressed():
		QUERY = "a=register&u="+username.get_text()+"&p="+password.get_text()
		
	var HEADERS = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
	$HTTPRequest.request("http://www.chrisnastovski.com/COP4331/api.php", HEADERS, true, HTTPClient.METHOD_POST, QUERY)
