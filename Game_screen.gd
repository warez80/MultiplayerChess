extends Container

onready var grid = [[$Chess_Board/r0c0, $Chess_Board/r0c1, $Chess_Board/r0c2, $Chess_Board/r0c3, $Chess_Board/r0c4, $Chess_Board/r0c5, $Chess_Board/r0c6, $Chess_Board/r0c7], [$Chess_Board/r1c0, $Chess_Board/r1c1, $Chess_Board/r1c2, $Chess_Board/r1c3, $Chess_Board/r1c4, $Chess_Board/r1c5, $Chess_Board/r1c6, $Chess_Board/r1c7], [$Chess_Board/r2c0, $Chess_Board/r2c1, $Chess_Board/r2c2, $Chess_Board/r2c3, $Chess_Board/r2c4, $Chess_Board/r2c5, $Chess_Board/r2c6, $Chess_Board/r2c7], [$Chess_Board/r3c0, $Chess_Board/r3c1, $Chess_Board/r3c2, $Chess_Board/r3c3, $Chess_Board/r3c4, $Chess_Board/r3c5, $Chess_Board/r3c6, $Chess_Board/r3c7], [$Chess_Board/r4c0, $Chess_Board/r4c1, $Chess_Board/r4c2, $Chess_Board/r4c3, $Chess_Board/r4c4, $Chess_Board/r4c5, $Chess_Board/r4c6, $Chess_Board/r4c7], [$Chess_Board/r5c0, $Chess_Board/r5c1, $Chess_Board/r5c2, $Chess_Board/r5c3, $Chess_Board/r5c4, $Chess_Board/r5c5, $Chess_Board/r5c6, $Chess_Board/r5c7], [$Chess_Board/r6c0, $Chess_Board/r6c1, $Chess_Board/r6c2, $Chess_Board/r6c3, $Chess_Board/r6c4, $Chess_Board/r6c5, $Chess_Board/r6c6, $Chess_Board/r6c7], [$Chess_Board/r7c0, $Chess_Board/r7c1, $Chess_Board/r7c2, $Chess_Board/r7c3, $Chess_Board/r7c4, $Chess_Board/r7c5, $Chess_Board/r7c6, $Chess_Board/r7c7]]

var TEX_BLACK_PAWN = preload("res://gamePieces/Black/pawnB.png")
var TEX_BLACK_KING = preload("res://gamePieces/Black/kingB.png")
var TEX_BLACK_ROOK = preload("res://gamePieces/Black/rookB.png")
var TEX_BLACK_QUEEN = preload("res://gamePieces/Black/queenB.png")
var TEX_BLACK_KNIGHT = preload("res://gamePieces/Black/knightB.png")
var TEX_BLACK_BISHOP = preload("res://gamePieces/Black/bishopB.png")
var TEX_WHITE_PAWN = preload("res://gamePieces/White/pawnW.png")
var TEX_WHITE_KING = preload("res://gamePieces/White/kingW.png")
var TEX_WHITE_ROOK = preload("res://gamePieces/White/rookW.png")
var TEX_WHITE_QUEEN = preload("res://gamePieces/White/queenW.png")
var TEX_WHITE_KNIGHT = preload("res://gamePieces/White/knightW.png")
var TEX_WHITE_BISHOP = preload("res://gamePieces/White/bishopW.png")

var selected_r = -1
var selected_c = -1

var was_pressed = false

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _process(delta):
	# Update chat
	$Chat_Box/BetterChat.text = ""
	for msg in global.chat_messages:
		$Chat_Box/BetterChat.add_text(msg + "\n")
	
	# Update piece icons
	for i in range(8):
		for j in range(8):
			match global.pieceTypes[i][j]:
				global.NONE:
					grid[i][j].icon = null
				global.BLACK_PAWN:
					grid[i][j].icon = TEX_BLACK_PAWN
				global.BLACK_ROOK:
					grid[i][j].icon = TEX_BLACK_ROOK
				global.BLACK_KING:
					grid[i][j].icon = TEX_BLACK_KING
				global.BLACK_KNIGHT:
					grid[i][j].icon = TEX_BLACK_KNIGHT
				global.BLACK_BISHOP:
					grid[i][j].icon = TEX_BLACK_BISHOP
				global.BLACK_QUEEN:
					grid[i][j].icon = TEX_BLACK_QUEEN
				global.WHITE_PAWN:
					grid[i][j].icon = TEX_WHITE_PAWN
				global.WHITE_ROOK:
					grid[i][j].icon = TEX_WHITE_ROOK
				global.WHITE_KING:
					grid[i][j].icon = TEX_WHITE_KING
				global.WHITE_KNIGHT:
					grid[i][j].icon = TEX_WHITE_KNIGHT
				global.WHITE_BISHOP:
					grid[i][j].icon = TEX_WHITE_BISHOP
				global.WHITE_QUEEN:
					grid[i][j].icon = TEX_WHITE_QUEEN
	
	var is_pressed = false
	for i in range(8):
		for j in range(8):
			if grid[i][j].pressed:
				if !was_pressed:
					select_tile(i, j)
				is_pressed = true
				break
	
	was_pressed = is_pressed

func select_tile(r, c):
	print(str(r) + str(c))
	if !global.my_turn:
		return
	if selected_r == -1 and selected_c == -1:
		if global.pieceTypes[r][c] == global.NONE or !can_move_piece(r, c):
			return
		selected_r = r
		selected_c = c
	else:
		if (selected_r == r and selected_c == c):
			selected_r = -1
			selected_c = -1
			
		move_piece(selected_r, selected_c, r, c)

func move_piece(from_r, from_c, to_r, to_c):
	
	if is_valid(from_r, from_c, to_r, to_c):
		global.pieceTypes[to_r][to_c] = global.pieceTypes[from_r][from_c]
		global.pieceTypes[from_r][from_c] = global.NONE
		global.send_board_update()
		global.switch_turn()
		
	selected_r = -1
	selected_c = -1
	pass
	
func is_valid(from_r, from_c, to_r, to_c):
	var diff_r = from_r - to_r
	var diff_c = from_c - to_c
	match pieceTypes[from_r][from_c]:
		BLACK_PAWN:
			if(to_c == from_c and to_r == from_r+1):
				return true
		BLACK_ROOK:
			if((to_c == from_c or to_r == from_r) and !(to_c == from_c and to_r == from_r)):
				if is_blocked(from_r, from_c, to_r, to_c, sign(diff_r), sign(diff_c)):
					return true
		BLACK_KING:
			if abs(diff_c) <= 1 and abs(diff_r) <= 1:
				return true
		BLACK_KNIGHT:
			if abs(diff_c) == 1 and abs(diff_r) == 2:
				return true
			if abs(diff_r) == 1 and abs(diff_r) == 2:
				return true
		BLACK_BISHOP:
			if get_left_diag(to_r, to_c) == get_left_diag(from_r, from_c) or get_right_diag(to_r, to_c) == get_right_diag(from_r, from_c):
				return true
		BLACK_QUEEN:
			if get_left_diag(to_r, to_c) == get_left_diag(from_r, from_c) or get_right_diag(to_r, to_c) == get_right_diag(from_r, from_c):
				return true
			if((to_c == from_c or to_r == from_r) and !(to_c == from_c and to_r == from_r)):
				return true
		WHITE_PAWN:
			if(to_c == from_c and to_r == from_r-1):
				return true
		WHITE_ROOK:
			if((to_c == from_c or to_r == from_r) and !(to_c == from_c and to_r == from_r)):
				return true
		WHITE_KING:
			if abs(diff_c) <= 1 and abs(diff_r) <= 1:
				return true
		WHITE_KNIGHT:
			if abs(diff_c) == 1 and abs(diff_r) == 2:
				return true
			if abs(diff_r) == 1 and abs(diff_c) == 2:
				return true
		WHITE_BISHOP:
			if get_left_diag(to_r, to_c) == get_left_diag(from_r, from_c) or get_right_diag(to_r, to_c) == get_right_diag(from_r, from_c):
				return true
		WHITE_QUEEN:
			if get_left_diag(to_r, to_c) == get_left_diag(from_r, from_c) or get_right_diag(to_r, to_c) == get_right_diag(from_r, from_c):
				return true
			if((to_c == from_c or to_r == from_r) and !(to_c == from_c and to_r == from_r)):
				return true
	return false
	
func is_blocked(from_r, from_c, to_r, to_c, dr, dc):
	var r = from_r + dr
	var c = from_c + dc
	while r != to_r and c != to_c and in_bounds(r, c):
		if pieceTypes[r][c] != NONE:
			return true
		r += dr
		c += dc
	return false

func in_bounds(r, c):
	return r >= 0 and r < 8 and c >= 0 and c < 8
func get_left_diag(r, c):
	return r + c
func get_right_diag(r, c):
	return r + (8 - c)

func _on_SendChatButton_pressed():
	global.send_chat_to_server($Text_Input/ChatInputBox.text)
	$Text_Input/ChatInputBox.text = ""

func can_move_piece(r, c):
	match global.pieceTypes[r][c]:
		global.BLACK_ROOK, global.BLACK_KING, global.BLACK_BISHOP, global.BLACK_QUEEN, global.BLACK_PAWN, global.BLACK_KNIGHT:
			return global.my_type == global.BLACK
		global.WHITE_ROOK, global.WHITE_KING, global.WHITE_BISHOP, global.WHITE_QUEEN, global.WHITE_PAWN, global.WHITE_KNIGHT:
			return global.my_type == global.WHITE
		_:
			return false