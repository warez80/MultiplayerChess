extends Node

var GAME_PORT = 1234
var MAX_PLAYERS = 99

enum PlayerType { NONE, BLACK, WHITE }
enum PlayerRole { SPECTATOR, SERVER, CLIENT }

enum PieceType {NONE, BLACK_PAWN, BLACK_KNIGHT, BLACK_ROOK, BLACK_BISHOP, BLACK_QUEEN, BLACK_KING, WHITE_PAWN, WHITE_KNIGHT, WHITE_ROOK, WHITE_BISHOP, WHITE_QUEEN, WHITE_KING}

var auth_token = ""

var pieceTypes = []

var network_peer = null
var my_username = ""
var my_role = null
var my_type = NONE
var my_turn = false
var my_local_ip = IP.get_local_addresses()[4]

var client_init = false

var chat_messages = []

var player_info = {}

var fog_war = true

func init_game_board():
	for i in range(8):
		pieceTypes.append([NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE])
	
	for i in range(8):
		pieceTypes[1][i] = BLACK_PAWN
		pieceTypes[-2][i] = WHITE_PAWN
	
	pieceTypes[0][0] = BLACK_ROOK
	pieceTypes[0][-1] = BLACK_ROOK
	pieceTypes[0][1] = BLACK_KNIGHT
	pieceTypes[0][-2] = BLACK_KNIGHT
	pieceTypes[0][2] = BLACK_BISHOP
	pieceTypes[0][-3] = BLACK_BISHOP
	pieceTypes[0][3] = BLACK_QUEEN
	pieceTypes[0][-4] = BLACK_KING
	
	pieceTypes[-1][0] = WHITE_ROOK
	pieceTypes[-1][-1] = WHITE_ROOK
	pieceTypes[-1][1] = WHITE_KNIGHT
	pieceTypes[-1][-2] = WHITE_KNIGHT
	pieceTypes[-1][2] = WHITE_BISHOP
	pieceTypes[-1][-3] = WHITE_BISHOP
	pieceTypes[-1][3] = WHITE_QUEEN
	pieceTypes[-1][-4] = WHITE_KING

func _ready():
	get_tree().connect("network_peer_disconnected", self, "_client_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")

func _client_disconnected(id):
	player_info.erase(id)

remote func register_player(id, username):
	rpc_id(id, "receive_board_update", pieceTypes)
	broadcast_message(username + " has joined the chat.")

	if client_init:
		rpc_id(id, "set_role", SPECTATOR)
		player_info[id] = {"id": id, "role": SPECTATOR, "username": username}
	else:
		rpc_id(id, "set_role", CLIENT)
		client_init = true
		player_info[id] = {"id": id, "role": CLIENT, "username": username}
		broadcast_message(username + " will be playing as white.")
	
	for id in player_info:
		rpc_id(id, "update_player_info", player_info)

func setup_game(ip):
	init_game_board()
	my_type = BLACK
	my_turn = false
	my_role = SERVER
	network_peer = NetworkedMultiplayerENet.new()
	network_peer.create_server(GAME_PORT, MAX_PLAYERS)
	client_init = false
	# TODO: contact chris's server with `ip`
	#get_tree().change_scene("res://Game_screen.tscn")
	player_info[0] = {"id": 0, "role": SERVER, "username": my_username}
	get_tree().set_network_peer(network_peer)

func broadcast_message(message):
	for id in player_info:
		rpc_id(id, "receive_chat_broadcast_from_server", message)
	receive_chat_broadcast_from_server(message)

remote func receive_chat_from_client(username, message):
	broadcast_message("<" + username + "> " + message)

remote func receive_chat_broadcast_from_server(message):
	print(message)
	chat_messages.append(message)
	
func send_chat_to_server(message):
	if my_role == SERVER:
		receive_chat_from_client(my_username, message)
	else:
		rpc("receive_chat_from_client", my_username, message)

remote func receive_board_update(board):
	pieceTypes = board

func send_board_update():
	if my_role == SERVER:
		send_board_update_to_all_clients()
	elif my_role == CLIENT:
		rpc("receive_board_update", pieceTypes)
		rpc("send_board_update_to_all_clients")

remote func send_board_update_to_all_clients():
	for id in player_info:
		rpc_id(id, "receive_board_update", pieceTypes)

remote func set_role(role):
	my_role = role
	if role == CLIENT:
		my_type = WHITE
		my_turn = true
	elif role == SPECTATOR:
		my_type = NONE

func switch_turn():
	if !my_turn:
		return
	if my_role == SERVER:
		receive_turn(CLIENT)
		send_turn_update_to_all_clients(CLIENT)
	elif my_role == CLIENT:
		rpc("receive_turn", SERVER)
		rpc("send_turn_update_to_all_clients", SERVER)

remote func send_turn_update_to_all_clients(role):
	for id in player_info:
		rpc_id(id, "receive_turn", role)

remote func receive_turn(role):
	my_turn = (my_role == role)

func _connected_ok():
	rpc("register_player", get_tree().get_network_unique_id(), my_username)

func connect(ip):
	init_game_board()
	network_peer = NetworkedMultiplayerENet.new()
	network_peer.create_client(ip, GAME_PORT)
	chat_messages = []
	get_tree().change_scene("res://lobby.tscn")
	get_tree().set_network_peer(network_peer)
	
remote func update_player_info(players):
	player_info = players

# Called by host to start game
func host_start_game():
	get_tree().change_scene("res://Game_Screen.tscn")
	for id in player_info:
		rpc_id(id, "host_started_game")
		
# called when host starts game
remote func host_started_game():
	get_tree().change_scene("res://Game_Screen.tscn")