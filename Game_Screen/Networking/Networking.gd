extends Node

# NETWORK DATA
# Port Tip: Check the web for available ports that is not preoccupied by other important services
# Port Tip #2: If you are the server; you may want to open it (NAT, Firewall)
const SERVER_PORT = 31416

# GAMEDATA
var players = {} # Dictionary containing player names and their ID
var player_name # Your own player name

# SIGNALS to Main Menu (GUI)
signal refresh_lobby()
signal server_ended()
signal server_error()
signal connection_success()
signal connection_fail()


# Join a server
func join_game(name, ip_address):
	# Store own player name
	player_name = name
	
	# Initializing the network as server
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip_address, SERVER_PORT)
	get_tree().set_network_peer(host)

# Host the server
func host_game(name):
	# Store own player name
	player_name = name
	
	# Initializing the network as client
	var host = NetworkedMultiplayerENet.new()
	host.create_server(SERVER_PORT, 6) # Max 6 players can be connected
	get_tree().set_network_peer(host)


func _ready():
	# Networking signals (high level networking)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


# Client connected with you (can be both server or client)
func _player_connected(id):
	pass


# Client disconnected from you
func _player_disconnected(id):
	# If I am server, send a signal to inform that an player disconnected
	unregister_player(id)
	rpc("unregister_player", id)


# Successfully connected to server (client)
func _connected_ok():
	# Send signal to server that we are ready to be assigned;
	# Either to lobby or ingame
	rpc_id(1, "user_ready", get_tree().get_network_unique_id(), player_name)
	pass


# Server receives this from players that have just connected
remote func user_ready(id, player_name):
	# Only the server can run this!
	if(get_tree().is_network_server()):
		# If we are ingame, add player to session, else send to lobby	
		if(has_node("/root/world")):
			rpc_id(id, "register_in_game")
		else:
			rpc_id(id, "register_at_lobby")


# Register yourself directly ingame
remote func register_in_game():
	rpc("register_new_player", get_tree().get_network_unique_id(), player_name)
	register_new_player(get_tree().get_network_unique_id(), player_name)


# Register myself with other players at lobby
remote func register_at_lobby():
	rpc("register_player", get_tree().get_network_unique_id(), player_name)
	emit_signal("connection_success") # Sends command to gui & will send player to lobby


# Could not connect to server (client)
func _connected_fail():
	get_tree().set_network_peer(null)
	emit_signal("connection_fail")


# Server disconnected (client)
func _server_disconnected():
	quit_game()
	emit_signal("server_ended")


# Register the player and jump ingame
remote func register_new_player(id, name):
	# This runs only once from server
	if(get_tree().is_network_server()):
		# Send info about server to new player
		rpc_id(id, "register_new_player", 1, player_name) 
		
		# Send the new player info about the other players
		for peer_id in players:
			rpc_id(id, "register_new_player", peer_id, players[peer_id]) 
	
	# Add new player to your player list
	players[id] = name


# Register player the ol' fashioned way and refresh lobby
remote func register_player(id, name):
	# If I am the server (not run on clients)
	if(get_tree().is_network_server()):
		rpc_id(id, "register_player", 1, player_name) # Send info about server to new player
		
		# For each player, send the new guy info of all players (from server)
		for peer_id in players:
			rpc_id(id, "register_player", peer_id, players[peer_id]) # Send the new player info about others
			rpc_id(peer_id, "register_player", id, name) # Send others info about the new player
	
	players[id] = name # update player list

	# Notify lobby (GUI) about changes
	emit_signal("refresh_lobby")


# Unregister a player, whether he is in lobby or ingame
remote func unregister_player(id):
	# If the game is running
	if(has_node("/root/world")):
		# Remove player from game
		if(has_node("/root/world/players/" + str(id))):
			get_node("/root/world/players/" + str(id)).queue_free()
		players.erase(id)
	else:
		# Remove from lobby
		players.erase(id)
		emit_signal("refresh_lobby")


# Returns a list of players (lobby)
func get_player_list():
	return players.values()


# Returns your name
func get_player_name():
	return player_name


# Quits the game, will automatically tell the server you disconnected; neat.
func quit_game():
	get_tree().set_network_peer(null)
	players.clear()