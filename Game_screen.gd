extends Container

onready var grid = [[$Chess_Board/r0c0, $Chess_Board/r0c1, $Chess_Board/r0c2, $Chess_Board/r0c3, $Chess_Board/r0c4, $Chess_Board/r0c5, $Chess_Board/r0c6, $Chess_Board/r0c7], [$Chess_Board/r1c0, $Chess_Board/r1c1, $Chess_Board/r1c2, $Chess_Board/r1c3, $Chess_Board/r1c4, $Chess_Board/r1c5, $Chess_Board/r1c6, $Chess_Board/r1c7], [$Chess_Board/r2c0, $Chess_Board/r2c1, $Chess_Board/r2c2, $Chess_Board/r2c3, $Chess_Board/r2c4, $Chess_Board/r2c5, $Chess_Board/r2c6, $Chess_Board/r2c7], [$Chess_Board/r3c0, $Chess_Board/r3c1, $Chess_Board/r3c2, $Chess_Board/r3c3, $Chess_Board/r3c4, $Chess_Board/r3c5, $Chess_Board/r3c6, $Chess_Board/r3c7], [$Chess_Board/r4c0, $Chess_Board/r4c1, $Chess_Board/r4c2, $Chess_Board/r4c3, $Chess_Board/r4c4, $Chess_Board/r4c5, $Chess_Board/r4c6, $Chess_Board/r4c7], [$Chess_Board/r5c0, $Chess_Board/r5c1, $Chess_Board/r5c2, $Chess_Board/r5c3, $Chess_Board/r5c4, $Chess_Board/r5c5, $Chess_Board/r5c6, $Chess_Board/r5c7], [$Chess_Board/r6c0, $Chess_Board/r6c1, $Chess_Board/r6c2, $Chess_Board/r6c3, $Chess_Board/r6c4, $Chess_Board/r6c5, $Chess_Board/r6c6, $Chess_Board/r6c7], [$Chess_Board/r7c0, $Chess_Board/r7c1, $Chess_Board/r7c2, $Chess_Board/r7c3, $Chess_Board/r7c4, $Chess_Board/r7c5, $Chess_Board/r7c6, $Chess_Board/r7c7]]

enum PieceType {NONE, BLACK_PAWN, BLACK_KNIGHT, BLACK_ROOK, BLACK_BISHOP, BLACK_QUEEN, BLACK_KING, WHITE_PAWN, WHITE_KNIGHT, WHITE_ROOK, WHITE_BISHOP, WHITE_QUEEN, WHITE_KING}

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

var pieceTypes = []

var selected_r = -1
var selected_c = -1

var was_pressed = false

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
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
	
	pass

func _process(delta):
	
	# Update piece icons
	for i in range(8):
		for j in range(8):
			match pieceTypes[i][j]:
				NONE:
					grid[i][j].icon = null
				BLACK_PAWN:
					grid[i][j].icon = TEX_BLACK_PAWN
				BLACK_ROOK:
					grid[i][j].icon = TEX_BLACK_ROOK
				BLACK_KING:
					grid[i][j].icon = TEX_BLACK_KING
				BLACK_KNIGHT:
					grid[i][j].icon = TEX_BLACK_KNIGHT
				BLACK_BISHOP:
					grid[i][j].icon = TEX_BLACK_BISHOP
				BLACK_QUEEN:
					grid[i][j].icon = TEX_BLACK_QUEEN
				WHITE_PAWN:
					grid[i][j].icon = TEX_WHITE_PAWN
				WHITE_ROOK:
					grid[i][j].icon = TEX_WHITE_ROOK
				WHITE_KING:
					grid[i][j].icon = TEX_WHITE_KING
				WHITE_KNIGHT:
					grid[i][j].icon = TEX_WHITE_KNIGHT
				WHITE_BISHOP:
					grid[i][j].icon = TEX_WHITE_BISHOP
				WHITE_QUEEN:
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
	
	pass

func select_tile(r, c):
	print(str(r) + str(c))
	if selected_r == -1 and selected_c == -1:
		if pieceTypes[r][c] == NONE:
			return
		selected_r = r
		selected_c = c
	else:
		move_piece(selected_r, selected_c, r, c)
	pass

func move_piece(from_r, from_c, to_r, to_c):
	pieceTypes[to_r][to_c] = pieceTypes[from_r][from_c]
	pieceTypes[from_r][from_c] = NONE
	selected_r = -1
	selected_c = -1
	pass