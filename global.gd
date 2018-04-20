extends Node

var GAME_PORT = 1234
var MAX_PLAYERS = 99

enum PlayerType { NONE, BLACK, WHITE }
enum PlayerRole { SPECTATOR, SERVER, CLIENT }

enum PieceType {NONE, BLACK_PAWN, BLACK_KNIGHT, BLACK_ROOK, BLACK_BISHOP, BLACK_QUEEN, BLACK_KING, WHITE_PAWN, WHITE_KNIGHT, WHITE_ROOK, WHITE_BISHOP, WHITE_QUEEN, WHITE_KING}
onready var piece_strings = ["NONE", "Black Pawn", "Black Knight", "Black Rook", "Black Bishop", "Black Queen", "Black King", "White Pawn", "White Knight", "White Rook", "White Bishop", "White Queen", "White King"]
onready var row_strings = ["8", "7", "6", "5", "4", "3", "2", "1"]
onready var col_strings = ["a", "b", "c", "d", "e", "f", "g", "h"]
var auth_token = ""

var pieceTypes = []
var temp_board = []

onready var turn_num = 1

var network_peer = null
var my_username = ""
var my_role = null
var my_type = NONE
var my_turn = false
var my_local_ip = "127.0.0.1" # IP.get_local_addresses()[4]

var client_init = false

var chat_messages = []
var move_messages = []

var player_info = {}

var fog_war = false

func init_game_board():
	# 0-7=board, 8-9= en passant, 10-11 = castling
	
	for i in range(10):
		pieceTypes.append([NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE])
	
	pieceTypes.append([WHITE_ROOK, NONE, NONE, NONE,WHITE_KING, NONE, NONE, WHITE_ROOK])
	pieceTypes.append([BLACK_ROOK, NONE, NONE, BLACK_KING, NONE , NONE, NONE, BLACK_ROOK])
	
	for i in range(8):
		pieceTypes[1][i] = BLACK_PAWN
		pieceTypes[6][i] = WHITE_PAWN
	
	pieceTypes[0][0] = BLACK_ROOK
	pieceTypes[0][7] = BLACK_ROOK
	pieceTypes[0][1] = BLACK_KNIGHT
	pieceTypes[0][6] = BLACK_KNIGHT
	pieceTypes[0][2] = BLACK_BISHOP
	pieceTypes[0][5] = BLACK_BISHOP
	pieceTypes[0][3] = BLACK_QUEEN
	pieceTypes[0][4] = BLACK_KING
	
	pieceTypes[7][0] = WHITE_ROOK
	pieceTypes[7][7] = WHITE_ROOK
	pieceTypes[7][1] = WHITE_KNIGHT
	pieceTypes[7][6] = WHITE_KNIGHT
	pieceTypes[7][2] = WHITE_BISHOP
	pieceTypes[7][5] = WHITE_BISHOP
	pieceTypes[7][3] = WHITE_QUEEN
	pieceTypes[7][4] = WHITE_KING
	
#	# For fool's mate test
#	temp_board = []
#	for i in range(10):
#		temp_board.append([NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE])
#
#	temp_board[1][0] = BLACK_PAWN
#	temp_board[1][1] = BLACK_PAWN
#	temp_board[1][2] = BLACK_PAWN
#	temp_board[1][3] = BLACK_PAWN
#	temp_board[3][4] = BLACK_PAWN
#	temp_board[1][5] = BLACK_PAWN
#	temp_board[1][6] = BLACK_PAWN
#	temp_board[1][7] = BLACK_PAWN
#
#	temp_board[6][0] = WHITE_PAWN
#	temp_board[6][1] = WHITE_PAWN
#	temp_board[6][2] = WHITE_PAWN
#	temp_board[6][3] = WHITE_PAWN
#	temp_board[6][4] = WHITE_PAWN
#	temp_board[5][5] = WHITE_PAWN
#	temp_board[4][6] = WHITE_PAWN
#	temp_board[6][7] = WHITE_PAWN
#
#	temp_board[0][0] = BLACK_ROOK
#	temp_board[0][7] = BLACK_ROOK
#	temp_board[0][1] = BLACK_KNIGHT
#	temp_board[0][6] = BLACK_KNIGHT
#	temp_board[0][2] = BLACK_BISHOP
#	temp_board[0][5] = BLACK_BISHOP
#	temp_board[4][7] = BLACK_QUEEN
#	temp_board[0][4] = BLACK_KING
#
#	temp_board[7][0] = WHITE_ROOK
#	temp_board[7][7] = WHITE_ROOK
#	temp_board[7][1] = WHITE_KNIGHT
#	temp_board[7][6] = WHITE_KNIGHT
#	temp_board[7][2] = WHITE_BISHOP
#	temp_board[7][5] = WHITE_BISHOP
#	temp_board[7][3] = WHITE_QUEEN
#	temp_board[7][4] = WHITE_KING

func _ready():
	get_tree().connect("network_peer_disconnected", self, "_client_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")

func _client_disconnected(id):
	player_info.erase(id)

remote func register_player(id, username):
	rpc_id(id, "receive_board_update", pieceTypes)
	rpc_id(id, "receive_moves_update", move_messages)
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
	chat_messages = []
	move_messages = []
	# TODO: contact chris's server with `ip`
	#get_tree().change_scene("res://Game_screen.tscn")
	player_info[0] = {"id": 0, "role": SERVER, "username": my_username}
	get_tree().set_network_peer(network_peer)

func broadcast_message(message):
	print("Broadcasting message " + message)
	print(player_info)
	for id in player_info:
		if id < 1:
			continue
		print("Sending chat to :" + str(id) + message)
		rpc_id(id, "receive_chat_broadcast_from_server", message)
	receive_chat_broadcast_from_server(message)

remote func receive_chat_from_client(username, message):
	print("Received from client: " + message)
	broadcast_message("<" + username + "> " + message)

remote func receive_chat_broadcast_from_server(message):
	print("Received: " + message)
	chat_messages.append(message)
	
func send_chat_to_server(message):
	print("Sending: " + message)
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

remote func receive_moves_update(moves):
	move_messages = moves

func send_moves_update():
	if my_role == SERVER:
		send_moves_update_to_all_clients()
	elif my_role == CLIENT:
		rpc("receive_moves_update", move_messages)
		rpc("send_moves_update_to_all_clients")

remote func send_moves_update_to_all_clients():
	for id in player_info:
		rpc_id(id, "receive_moves_update", move_messages)

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
	turn_num += 1
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
	move_messages = []
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
	
# add string to move list
func add_move_to_list(move_str):
	if fog_war:
		move_messages.append("MOVE HIDDEN DUE TO FOG")
	else:
		move_messages.append(move_str)
	send_moves_update()

func gen_move_str(from_r, from_c, to_r, to_c):
	var piece = piece_strings[pieceTypes[from_r][from_c]]
	return "%s. %s: %s%s -> %s%s" % [str(turn_num), piece, col_strings[from_c], row_strings[from_r], col_strings[to_c], row_strings[to_r]]
	