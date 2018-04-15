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
var TEX_FOG = preload("res://fog.png")

var selected_r = -1
var selected_c = -1

var selected_theme
var move_theme

var was_pressed = false

var visible_grid
var dr = [-1,  0,  1, 1, 1, 0, -1, -1]
var dc = [-1, -1, -1, 0, 1, 1,  1,  0]

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	selected_theme = preload("res://selected_theme.tres")
	move_theme = preload("res://move_theme.tres")
	visible_grid = []
	for x in range(8):
    	visible_grid.append([])
	    for y in range(8):
        	visible_grid[x].append(false)
	pass

func _process(delta):
	# Update chat
	$Chat_Box/BetterChat.text = ""
	for msg in global.chat_messages:
		$Chat_Box/BetterChat.add_text(msg + "\n")
		
	# Update visibility
	if global.fog_war:
		for i in range(8):
			for j in range(8):
				visible_grid[i][j] = false
				
		for i in range(8):
			for j in range(8):
				if can_move_piece(i, j):
					visible_grid[i][j] = true
					for d in range(dr.size()):
						if in_bounds(i+dr[d], j+dc[d]):
							visible_grid[i+dr[d]][j+dc[d]] = true
	
	# Update piece icons
	for i in range(8):
		for j in range(8):
			if !global.fog_war or visible_grid[i][j]:
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
			else:
				grid[i][j].icon = TEX_FOG
	
	var is_pressed = false
	for i in range(8):
		for j in range(8):
			if grid[i][j].pressed:
				if !was_pressed:
					select_tile(i, j)
				is_pressed = true
				break
	
	was_pressed = is_pressed
	
	for i in range(8):
		for j in range(8):
			grid[i][j].set_flat(true)
			grid[i][j].set_theme(null)
	
			
	if selected_r != -1 and selected_c != -1:
		grid[selected_r][selected_c].set_flat(false)
		grid[selected_r][selected_c].set_theme(selected_theme)
		
		for i in range(8):
			for j in range(8):
				if is_valid(selected_r, selected_c, i, j):
					grid[i][j].set_flat(false)
					grid[i][j].set_theme(move_theme)

func select_tile(r, c):
	print(str(r) + str(c))
	if !global.my_turn:
		selected_r = -1
		selected_c = -1
		return
	elif selected_r == -1 and selected_c == -1:
		if global.pieceTypes[r][c] == global.NONE or !can_move_piece(r, c):
			return
		selected_r = r
		selected_c = c
		
	elif selected_r == r and selected_c == c:
		selected_r = -1
		selected_c = -1
	else:
		move_piece(selected_r, selected_c, r, c)
		selected_r=-1
		selected_c=-1
	pass

# Just deals with buttons for now
func toggle_selection(r, c):
	if(!grid[r][c].get_theme().equals(selected_theme)):
		grid[r][c].set_theme(selected_theme)
	else:
		grid[r][c].set_theme(null)
	pass

func move_piece(from_r, from_c, to_r, to_c):
	if is_valid(from_r, from_c, to_r, to_c):
		if global.my_type == global.BLACK:
			for i in range(8):
				global.pieceTypes[8][i]=global.NONE
		if global.my_type == global.WHITE:
			for i in range(8):
				global.pieceTypes[9][i]=global.NONE
		global.pieceTypes[to_r][to_c] = global.pieceTypes[from_r][from_c]
		global.pieceTypes[from_r][from_c] = global.NONE
		global.send_board_update()
		global.switch_turn()
		selected_r = -1
		selected_c = -1
	
func is_valid(from_r, from_c, to_r, to_c):
	#print("valid: from_r = "+str(from_r)+"| from_c = "+str(from_c))
	#print("     : to_r = "+str(from_r)+"| to_c = "+str(from_c))
	#print("     : piece = "+str(global.pieceTypes[from_r][from_c]))
	if from_r == to_r and from_c == to_c:
		return false
	if can_move_piece(to_r, to_c) and global.pieceTypes[to_r][to_c] != global.NONE:
		return false
		
	var diff_r = from_r - to_r
	var diff_c = from_c - to_c
	match global.pieceTypes[from_r][from_c]:
		global.BLACK_PAWN:
			if (to_c == from_c and to_r == from_r+1 and global.pieceTypes[to_r][to_c] == global.NONE):
				return true
			elif ((to_c == from_c + 1 or to_c == from_c - 1 ) and to_r == from_r + 1 and global.pieceTypes[to_r][to_c]!=global.NONE and !can_move_piece(to_r, to_c)):
				return true
			elif to_c == from_c and from_r == 1 and to_r == 3 and global.pieceTypes[to_r][to_c]==global.NONE and global.pieceTypes[to_r-1][to_c]==global.NONE:
				global.pieceTypes[9][to_c]=global.BLACK_PAWN
				return true
			elif abs(diff_c)==1 and to_r==from_r+1 and to_r == 5 and global.pieceTypes[8][to_c]==global.WHITE_PAWN:
				global.pieceTypes[4][to_c]=global.NONE
				return true
		global.BLACK_ROOK:
			if ((to_c == from_c or to_r == from_r) and !(to_c == from_c and to_r == from_r)) and !is_blocked(from_r, from_c, to_r, to_c):
				if from_c==0 and from_r==0:
					global.pieceTypes[11][0]=global.NONE
				if from_c==7 and from_r==0:
					global.pieceTypes[11][7]=global.NONE
				return true
		global.BLACK_KING:
			if abs(diff_c) <= 1 and abs(diff_r) <= 1 and !is_blocked(from_r, from_c, to_r, to_c):
				global.pieceTypes[11][4]=global.NONE
				return true
			elif global.pieceTypes[11][4]==global.BLACK_KING and from_r==0 and from_c==4 and global.pieceTypes[11][0]==global.BLACK_ROOK and to_r==0 and to_c==2:
				if global.pieceTypes[0][1]==global.NONE and global.pieceTypes[0][2]==global.NONE and global.pieceTypes[0][3]==global.NONE:
					global.pieceTypes[0][0]=global.NONE
					global.pieceTypes[0][3]=global.WHITE_ROOK
					return true
			elif global.pieceTypes[11][4]==global.BLACK_KING and from_r==0 and from_c==4 and global.pieceTypes[11][7]==global.BLACK_KING and to_r==0 and to_c==6:
				if global.pieceTypes[0][5]==global.NONE and global.pieceTypes[0][6]==global.NONE:
					global.pieceTypes[0][7]=global.NONE
					global.pieceTypes[0][5]=global.WHITE_ROOK
					return true
		global.BLACK_KNIGHT:
			if abs(diff_c) == 1 and abs(diff_r) == 2 and !can_move_piece(to_r, to_c):
				return true
			if abs(diff_r) == 1 and abs(diff_c) == 2 and !can_move_piece(to_r, to_c):
				return true
		global.BLACK_BISHOP:
			if get_left_diag(to_r, to_c) == get_left_diag(from_r, from_c) or get_right_diag(to_r, to_c) == get_right_diag(from_r, from_c):
				if !is_blocked(from_r, from_c, to_r, to_c):
					return true
		global.BLACK_QUEEN:
			if get_left_diag(to_r, to_c) == get_left_diag(from_r, from_c) or get_right_diag(to_r, to_c) == get_right_diag(from_r, from_c):
				if !is_blocked(from_r, from_c, to_r, to_c):
					return true
			if((to_c == from_c or to_r == from_r) and !(to_c == from_c and to_r == from_r)):
				return true
		global.WHITE_PAWN:
			if(to_c == from_c and to_r == from_r-1 and global.pieceTypes[to_r][to_c] == global.NONE):
				return true
			elif ((to_c == from_c + 1 or to_c == from_c - 1 ) and to_r == from_r - 1 and global.pieceTypes[to_r][to_c]!=global.NONE and !can_move_piece(to_r, to_c)):
				return true
			elif to_c == from_c and from_r == 6 and to_r == 4 and global.pieceTypes[to_r][to_c]==global.NONE and global.pieceTypes[to_r+1][to_c]==global.NONE:
				global.pieceTypes[8][to_c]=global.WHITE_PAWN
				return true
			elif abs(diff_c)==1 and to_r==from_r-1 and to_r == 2 and global.pieceTypes[9][to_c]==global.BLACK_PAWN:
				global.pieceTypes[3][to_c]=global.NONE
				return true
		global.WHITE_ROOK:
			if ((to_c == from_c or to_r == from_r) and !(to_c == from_c and to_r == from_r)) and !is_blocked(from_r, from_c, to_r, to_c):
				if from_c==0 and from_r==7:
					global.pieceTypes[10][0]=global.NONE
				if from_c==7 and from_r==7:
					global.pieceTypes[10][7]=global.NONE
				return true
		global.WHITE_KING:
			if abs(diff_c) <= 1 and abs(diff_r) <= 1 and is_blocked(from_r, from_c, to_r, to_c):
				global.pieceTypes[10][4]=global.NONE
				return true
			elif global.pieceTypes[10][4]==global.WHITE_KING and from_r==7 and from_c==4 and global.pieceTypes[10][0]==global.WHITE_ROOK and to_r==7 and to_c==2:
				if global.pieceTypes[7][1]==global.NONE and global.pieceTypes[7][2]==global.NONE and global.pieceTypes[7][3]==global.NONE:
					global.pieceTypes[7][0]=global.NONE
					global.pieceTypes[7][3]=global.WHITE_ROOK
					return true
			elif global.pieceTypes[10][4]==global.WHITE_KING and from_r==7 and from_c==4 and global.pieceTypes[10][7]==global.WHITE_ROOK and to_r==7 and to_c==6:
				if global.pieceTypes[7][5]==global.NONE and global.pieceTypes[7][6]==global.NONE:
					global.pieceTypes[7][7]=global.NONE
					global.pieceTypes[7][5]=global.WHITE_ROOK
					return true
		global.WHITE_KNIGHT:
			if abs(diff_c) == 1 and abs(diff_r) == 2 and !can_move_piece(to_r, to_c):
				return true
			if abs(diff_r) == 1 and abs(diff_c) == 2 and !can_move_piece(to_r, to_c):
				return true
		global.WHITE_BISHOP:
			if get_left_diag(to_r, to_c) == get_left_diag(from_r, from_c) or get_right_diag(to_r, to_c) == get_right_diag(from_r, from_c):
				if !is_blocked(from_r, from_c, to_r, to_c):
					return true
		global.WHITE_QUEEN:
			if get_left_diag(to_r, to_c) == get_left_diag(from_r, from_c) or get_right_diag(to_r, to_c) == get_right_diag(from_r, from_c):
				if !is_blocked(from_r, from_c, to_r, to_c):
					return true
			if((to_c == from_c or to_r == from_r) and !(to_c == from_c and to_r == from_r)):
				if !is_blocked(from_r, from_c, to_r, to_c):
					return true
	return false
	
func is_blocked_cardinal(from_r, from_c, to_r, to_c):
	
	return false
	
func is_blocked(from_r, from_c, to_r, to_c):
	var dr = sign(to_r - from_r)
	var dc = sign(to_c - from_c)
	
	var r = from_r + dr
	var c = from_c + dc
	
	while r != to_r or c != to_c:
		print("BLOCK: r = "+str(r)+"| c = "+str(c))
		if r < 0 or r >= 8 or c < 0 or c >= 8:
			print("ERROR: Out of bounds when checking DIAGONALS for BLOCKS")
			return true
		if global.pieceTypes[r][c] != global.NONE:
			return true
		r += dr
		c += dc
		
	if can_move_piece(to_r, to_c):
		return true
	
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

# If the piece at rc is yours, return false, otherwise, true
func can_move_piece(r, c):
	match global.pieceTypes[r][c]:
		global.BLACK_ROOK, global.BLACK_KING, global.BLACK_BISHOP, global.BLACK_QUEEN, global.BLACK_PAWN, global.BLACK_KNIGHT:
			return global.my_type == global.BLACK
		global.WHITE_ROOK, global.WHITE_KING, global.WHITE_BISHOP, global.WHITE_QUEEN, global.WHITE_PAWN, global.WHITE_KNIGHT:
			return global.my_type == global.WHITE
		_:
			return false