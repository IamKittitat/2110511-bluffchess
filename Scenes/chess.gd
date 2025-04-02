extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 18

const TEXTURE_HOLDER = preload("res://Scenes/texture_holder.tscn")

const BLACK_BISHOP = preload("res://Assets/Piece/black_bishop.png")
const BLACK_KING = preload("res://Assets/Piece/black_king.png")
const BLACK_KNIGHT = preload("res://Assets/Piece/black_knight.png")
const BLACK_PAWN = preload("res://Assets/Piece/black_pawn.png")
const BLACK_QUEEN = preload("res://Assets/Piece/black_queen.png")
const BLACK_ROOK = preload("res://Assets/Piece/black_rook.png")
const BLACK_HIDDEN_BISHOP = preload("res://Assets/Piece/black_hidden_bishop.png")
const BLACK_HIDDEN_KING = preload("res://Assets/Piece/black_hidden_king.png")
const BLACK_HIDDEN_KNIGHT = preload("res://Assets/Piece/black_hidden_knight.png")
const BLACK_HIDDEN_PAWN = preload("res://Assets/Piece/black_hidden_pawn.png")
const BLACK_HIDDEN_QUEEN = preload("res://Assets/Piece/black_hidden_queen.png")
const BLACK_HIDDEN_ROOK = preload("res://Assets/Piece/black_hidden_rook.png")
const BLACK_HIDDEN = preload("res://Assets/Piece/black_hidden.png")
const WHITE_BISHOP = preload("res://Assets/Piece/white_bishop.png")
const WHITE_KING = preload("res://Assets/Piece/white_king.png")
const WHITE_KNIGHT = preload("res://Assets/Piece/white_knight.png")
const WHITE_PAWN = preload("res://Assets/Piece/white_pawn.png")
const WHITE_QUEEN = preload("res://Assets/Piece/white_queen.png")
const WHITE_ROOK = preload("res://Assets/Piece/white_rook.png")
const WHITE_HIDDEN_BISHOP = preload("res://Assets/Piece/white_hidden_bishop.png")
const WHITE_HIDDEN_KING = preload("res://Assets/Piece/white_hidden_king.png")
const WHITE_HIDDEN_KNIGHT = preload("res://Assets/Piece/white_hidden_knight.png")
const WHITE_HIDDEN_PAWN = preload("res://Assets/Piece/white_hidden_pawn.png")
const WHITE_HIDDEN_QUEEN = preload("res://Assets/Piece/white_hidden_queen.png")
const WHITE_HIDDEN_ROOK = preload("res://Assets/Piece/white_hidden_rook.png")
const WHITE_HIDDEN = preload("res://Assets/Piece/white_hidden.png")

const TURN_WHITE = preload("res://Assets/turn-white.png")
const TURN_BLACK = preload("res://Assets/turn-black.png")

const PIECE_MOVE = preload("res://Assets/Piece_move.png")

@onready var pieces = $Pieces
@onready var dots = $Dots
@onready var turn = $Turn
@onready var white_pieces = $"../CanvasLayer/white_pieces"
@onready var black_pieces = $"../CanvasLayer/black_pieces"

#Variables
# -6 = black king
# -5 = black queen
# -4 = black rook
# -3 = black bishop
# -2 = black knight
# -1 = black pawn
# 0 = empty
# 6 = white king
# 5 = white queen
# 4 = white rook
# 3 = white bishop
# 2 = white knight
# 1 = white pawn

var board : Array
var hidden_board: Array # 0: No piece, 1 = Reveal, 2 = Hidden
var pawn_not_moved = _init_zero_array(BOARD_SIZE)
var is_my_turn: bool
var play_white : bool
var state : String = "CHOOSE" # CHOOSE, BLUFF, MOVE, CHALLENGE, SUCCESS, FAILED
var moves = []
var selected_piece : Vector2 # x = row, y = col
var disguise_code = 0
var opponent_disguise_code = 0
var opponent_dest_pos: Vector2

var promotion_square = null

# For Castling
#var white_king = false
#var black_king = false
#var white_rook_left = false
#var white_rook_right = false
#var black_rook_left = false
#var black_rook_right = false

#var en_passant = null

var white_king_pos
var black_king_pos

var fifty_move_rule = 0

var unique_board_moves : Array = []
var amount_of_same : Array = []

func _ready():
	play_white = GlobalScript.play_as == "white"
	

	board = GlobalScript.chess_board_data
	hidden_board = GlobalScript.hidden_board_data
	
	is_my_turn = play_white
	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			if row <= 1:
				pawn_not_moved[row][col] = 1
			if board[row][col] == 6:
				white_king_pos = Vector2(row, col)
			if board[row][col] == -6:
				black_king_pos = Vector2(row, col)
	display_board()
	
	var white_buttons = get_tree().get_nodes_in_group("white_pieces")
	var black_buttons = get_tree().get_nodes_in_group("black_pieces")
	
	# Signals
	for button in white_buttons:
		button.pressed.connect(self._on_button_pressed.bind(button))
		
	for button in black_buttons:
		button.pressed.connect(self._on_button_pressed.bind(button))
	
func _input(event):
	var peer_id = multiplayer.get_remote_sender_id()
	if event is InputEventMouseButton && event.pressed && promotion_square == null:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_mouse_out(): return
			if !is_my_turn: return
			
			var col = snapped(get_global_mouse_position().x, 0) / CELL_WIDTH # Find index on the board
			var row = abs(snapped(get_global_mouse_position().y, 0)) / CELL_WIDTH
			# Select pieces to move
			if state == "CHOOSE" && (play_white && board[row][col] > 0 || !play_white && board[row][col] < 0):
				selected_piece = Vector2(row, col)
				if(hidden_board[row][col] == 2):
					state = get_next_state(state)
				else:
					show_options(selected_piece, abs(board[row][col]))
					state = "MOVE"
			# Select pieces to disguise.
			elif state == "BLUFF":
				pass # This stage is handled by the piece disguise button
			elif state == "MOVE": 
				set_move(row, col)
				disguise_code = 0
				state = reset_state()
			elif state == "SUCCESS":
				if((play_white && board[row][col] < 0) || (!play_white && board[row][col] > 0)):
					if(hidden_board[row][col] == 2):
						hidden_board[row][col] = 1
						state = get_next_state(state)
						display_board()
						force_rerender.rpc_id(peer_id, board, hidden_board)
			elif state == "FAILED":
				if((play_white && board[row][col] > 0) || (!play_white && board[row][col] < 0)):
					board[row][col] = 0
					pawn_not_moved[row][col] = 0
					state = get_next_state(state)
					display_board()
					force_rerender.rpc_id(peer_id, board, hidden_board)
	
				
func is_mouse_out():
	if get_rect().has_point(to_local(get_global_mouse_position())): return false
	return true

func display_board():
	for child in pieces.get_children():
		child.queue_free()
	
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			var holder = TEXTURE_HOLDER.instantiate()
			pieces.add_child(holder)
			holder.global_position = Vector2(col * CELL_WIDTH + (CELL_WIDTH / 2), -row * CELL_WIDTH - (CELL_WIDTH / 2))
			
			if(board[row][col] > 0):
				if(hidden_board[row][col] == 1):
					match board[row][col]:
						6: holder.texture = WHITE_KING
						5: holder.texture = WHITE_QUEEN
						4: holder.texture = WHITE_ROOK
						3: holder.texture = WHITE_BISHOP
						2: holder.texture = WHITE_KNIGHT
						1: holder.texture = WHITE_PAWN
				else:
					if(play_white):
						match board[row][col]:
							6: holder.texture = WHITE_HIDDEN_KING
							5: holder.texture = WHITE_HIDDEN_QUEEN
							4: holder.texture = WHITE_HIDDEN_ROOK
							3: holder.texture = WHITE_HIDDEN_BISHOP
							2: holder.texture = WHITE_HIDDEN_KNIGHT
							1: holder.texture = WHITE_HIDDEN_PAWN
					else:
						holder.texture = WHITE_HIDDEN
			elif(board[row][col] < 0):
				if(hidden_board[row][col] == 1):
					match board[row][col]:
						-6: holder.texture = BLACK_KING
						-5: holder.texture = BLACK_QUEEN
						-4: holder.texture = BLACK_ROOK
						-3: holder.texture = BLACK_BISHOP
						-2: holder.texture = BLACK_KNIGHT
						-1: holder.texture = BLACK_PAWN
				else:
					if(!play_white):
						match board[row][col]:
							-6: holder.texture = BLACK_HIDDEN_KING
							-5: holder.texture = BLACK_HIDDEN_QUEEN
							-4: holder.texture = BLACK_HIDDEN_ROOK
							-3: holder.texture = BLACK_HIDDEN_BISHOP
							-2: holder.texture = BLACK_HIDDEN_KNIGHT
							-1: holder.texture = BLACK_HIDDEN_PAWN
					else:
						holder.texture = BLACK_HIDDEN
			else:
				holder.texture = null
			
			if holder.texture != null:
				holder.scale = Vector2(13.5 / holder.texture.get_width(), 13.5 / holder.texture.get_height())
			
	if play_white: turn.texture = TURN_WHITE
	else: turn.texture = TURN_BLACK

func show_options(selected_piece, disguise_piece_code):
	moves = get_moves(selected_piece, board[selected_piece.x][selected_piece.y], disguise_piece_code)
	if moves == []:
		state = reset_state()
		return
	show_dots()
	
func show_dots():
	for i in moves:
		var holder = TEXTURE_HOLDER.instantiate()
		dots.add_child(holder)
		holder.texture = PIECE_MOVE		
		holder.scale = Vector2(6.0 / holder.texture.get_width(), 6.0 / holder.texture.get_height())
		holder.global_position = Vector2(i.y * CELL_WIDTH + (CELL_WIDTH / 2), -i.x * CELL_WIDTH - (CELL_WIDTH / 2))

func delete_dots():
	for child in dots.get_children():
		child.queue_free()

func set_move(row, col):
	var peer_id = multiplayer.get_remote_sender_id()
	var just_now = false
	for i in moves:
		if i.x == row && i.y == col:
			fifty_move_rule += 1
			if is_enemy(Vector2(row, col)): fifty_move_rule = 0
			match board[selected_piece.x][selected_piece.y]:
				1:
					fifty_move_rule = 0
					if i.x == 7: promote(i)
					if i.x == 3 && selected_piece.x == 1:
						#en_passant = i
						just_now = true
					#elif en_passant != null:
						#if en_passant.y == i.y && selected_piece.y != i.y && en_passant.x == selected_piece.x:
							#board[en_passant.x][en_passant.y] = 0
				-1:
					fifty_move_rule = 0
					if i.x == 0: promote(i)
					if i.x == 4 && selected_piece.x == 6:
						#en_passant = i
						just_now = true
					#elif en_passzant != null:
						#if en_passant.y == i.y && selected_piece.y != i.y && en_passant.x == selected_piece.x:
							#board[en_passant.x][en_passant.y] = 0
				4:
					pass
					#if selected_piece.x == 0 && selected_piece.y == 0: white_rook_left = true
					#elif selected_piece.x == 0 && selected_piece.y == 7: white_rook_right = true
				-4:
					pass
					#if selected_piece.x == 7 && selected_piece.y == 0: black_rook_left = true
					#elif selected_piece.x == 7 && selected_piece.y == 7: black_rook_right = true
				6:
					#if selected_piece.x == 0 && selected_piece.y == 4:
						#white_king = true
						#if i.y == 2:
							#white_rook_left = true
							#white_rook_right = true
							#board[0][0] = 0
							#board[0][3] = 4
						#elif i.y == 6:
							#white_rook_left = true
							#white_rook_right = true
							#board[0][7] = 0
							#board[0][5] = 4
					white_king_pos = i
				-6:
					pass
					#if selected_piece.x == 7 && selected_piece.y == 4:
						#black_king = true
						#if i.y == 2:
							#black_rook_left = true
							#black_rook_right = true
							#board[7][0] = 0
							#board[7][3] = -4
						#elif i.y == 6:
							#black_rook_left = true
							#black_rook_right = true
							#board[7][7] = 0
							#board[7][5] = -4
					black_king_pos = i
			#if !just_now: en_passant = null
			
			_move(selected_piece, row, col)			
			is_my_turn = !is_my_turn 
			threefold_position(board)
			display_board()
			handle_opponent_move.rpc_id(peer_id, board, hidden_board, row, col, disguise_code)
			break
	delete_dots()
	state = reset_state()
	
	if(!opponent_king_exist()):
		self_handle_game_win()
		opponent_handle_game_lose.rpc_id(peer_id)
		
	# Can instantly switch to move another piece
	#if (selected_piece.x != var2 || selected_piece.y != var1) && (play_white && board[var2][var1] > 0 || !play_white && board[var2][var1] < 0):
		#selected_piece = Vector2(var2, var1)
		#print("HERE?", var2, var1)
		#show_options()
		#state = get_next_state(state)
	#elif is_stalemate():
		#if play_white && is_in_check(white_king_pos) || !play_white && is_in_check(black_king_pos): print("CHECKMATE")
		#else: print("DRAW")
		#
	#if fifty_move_rule == 50: print("DRAW")
	#elif insuficient_material(): print("DRAW")

func _move(selected_piece, row, col):
	board[row][col] = board[selected_piece.x][selected_piece.y]
	hidden_board[row][col] = hidden_board[selected_piece.x][selected_piece.y]
	board[selected_piece.x][selected_piece.y] = 0
	hidden_board[selected_piece.x][selected_piece.y] = 0
	pawn_not_moved[row][col] = 0

func self_handle_game_win():
	print("YOU WIN")
	
@rpc("any_peer", "call_remote", "reliable")
func handle_opponent_move(opponent_board, opponent_hidden_board, dest_row, dest_col, disguise_code):
	opponent_disguise_code = disguise_code
	dest_row = BOARD_SIZE - dest_row - 1
	dest_col = BOARD_SIZE - dest_col - 1
	opponent_dest_pos = Vector2(dest_row, dest_col)
	board = _flip_board(opponent_board)
	hidden_board = _flip_board(opponent_hidden_board)
	
	if(hidden_board[dest_row][dest_col] == 2):
		state = "CHALLENGE"
	else:
		state = "MOVE"
	# IF NOT PRESS CHALLENGE IN 5 SEC -> SKIPP 
			
	is_my_turn = !is_my_turn
	# CHOOSE, BLUFF, MOVE, CHALLENGE, SUCCESS, FAILED
	display_board()

@rpc("any_peer", "call_remote", "reliable")	
func force_rerender(opponent_board, opponent_hidden_board):
	board = _flip_board(opponent_board)
	hidden_board = _flip_board(opponent_hidden_board)
	display_board()
	
@rpc("any_peer", "call_remote", "reliable")
func opponent_handle_game_lose():
	print("YOU LOSE!")
	
func get_moves(selected, real_piece_code, disguise_piece_code):
	var _moves = []
	match abs(disguise_piece_code):
		1: _moves = get_pawn_moves(selected)
		2: _moves = get_knight_moves(selected)
		3: _moves = get_bishop_moves(selected)
		4: _moves = get_rook_moves(selected)
		5: _moves = get_queen_moves(selected)
		6: _moves = get_king_moves(selected)
	return _moves

func get_rook_moves(piece_position : Vector2):
	var _moves = []
	var directions = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0)]
	
	for i in directions:
		var destination_pos = piece_position
		destination_pos += i
		while is_valid_position(destination_pos):
			if is_empty(destination_pos):
				if _get_is_can_move(piece_position, destination_pos):
					_moves.append(destination_pos)
			elif is_enemy(destination_pos):
				if _get_is_can_move(piece_position, destination_pos):
					_moves.append(destination_pos)
				break
			else:
				break
			destination_pos += i
	
	return _moves
	
func get_bishop_moves(piece_position : Vector2):
	var _moves = []
	var directions = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
	
	for i in directions:
		var destination_pos = piece_position
		destination_pos += i
		while is_valid_position(destination_pos):
			if is_empty(destination_pos):
				if _get_is_can_move(piece_position, destination_pos):
					_moves.append(destination_pos)
			elif is_enemy(destination_pos):
				if _get_is_can_move(piece_position, destination_pos):
					_moves.append(destination_pos)
				break
			else:
				break

			destination_pos += i
	
	return _moves
	
func get_queen_moves(piece_position : Vector2):
	var _moves = []
	var directions = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0),
	Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
	
	for i in directions:
		var destination_pos = piece_position
		destination_pos += i
		while is_valid_position(destination_pos):
			if is_empty(destination_pos):
				if _get_is_can_move(piece_position, destination_pos):
					_moves.append(destination_pos)
			elif is_enemy(destination_pos):
				if _get_is_can_move(piece_position, destination_pos):
					_moves.append(destination_pos)
				break
			else:
				break
			destination_pos += i
	
	return _moves
	
func get_king_moves(piece_position : Vector2):
	var _moves = []
	var directions = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0),
	Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
	
	# Remove old position
	if play_white:
		board[white_king_pos.x][white_king_pos.y] = 0
	else:
		board[black_king_pos.x][black_king_pos.y] = 0
	
	for i in directions:
		var destination_pos = piece_position + i
		if is_valid_position(destination_pos):
			if !is_in_check(destination_pos):
				if is_empty(destination_pos): _moves.append(destination_pos)
				elif is_enemy(destination_pos):
					_moves.append(destination_pos)
				
	#if play_white && !white_king:
		#if !white_rook_left && is_empty(Vector2(0, 1)) && is_empty(Vector2(0, 2)) && !is_in_check(Vector2(0, 2)) && is_empty(Vector2(0, 3)) && !is_in_check(Vector2(0, 3)) && !is_in_check(Vector2(0, 4)):
			#_moves.append(Vector2(0, 2))
		#if !white_rook_right && !is_in_check(Vector2(0, 4)) && is_empty(Vector2(0, 5)) && !is_in_check(Vector2(0, 5)) && is_empty(Vector2(0, 6)) && !is_in_check(Vector2(0, 6)):
			#_moves.append(Vector2(0, 6))
	#elif !play_white && !black_king:
		#if !black_rook_left && is_empty(Vector2(7, 1)) && is_empty(Vector2(7, 2)) && !is_in_check(Vector2(7, 2)) && is_empty(Vector2(7, 3)) && !is_in_check(Vector2(7, 3)) && !is_in_check(Vector2(7, 4)):
			#_moves.append(Vector2(7, 2))
		#if !black_rook_right && !is_in_check(Vector2(7, 4)) && is_empty(Vector2(7, 5)) && !is_in_check(Vector2(7, 5)) && is_empty(Vector2(7, 6)) && !is_in_check(Vector2(7, 6)):
			#_moves.append(Vector2(7, 6))
			
	if play_white:
		board[white_king_pos.x][white_king_pos.y] = 6
	else:
		board[black_king_pos.x][black_king_pos.y] = -6
	
	return _moves
	
func get_knight_moves(piece_position : Vector2):
	var _moves = []
	var directions = [Vector2(2, 1), Vector2(2, -1), Vector2(1, 2), Vector2(1, -2),
	Vector2(-2, 1), Vector2(-2, -1), Vector2(-1, 2), Vector2(-1, -2)]
	
	for i in directions:
		var destination_pos = piece_position + i
		if is_valid_position(destination_pos):
			if is_empty(destination_pos) || is_enemy(destination_pos) && _get_is_can_move(piece_position, destination_pos):
				_moves.append(destination_pos)
	
	return _moves

func get_pawn_moves(piece_position : Vector2):
	var _moves = []
	var direction
	var is_first_move = pawn_not_moved[piece_position.x][piece_position.y] == 1
	direction = Vector2(1, 0)

	#if en_passant != null && (play_white && piece_position.x == 4 || !play_white && piece_position.x == 3) && abs(en_passant.y - piece_position.y) == 1:
		#var destination_pos = en_passant + direction
		#board[pos.x][pos.y] = 1 if play_white else -1
		#board[piece_position.x][piece_position.y] = 0
		#board[en_passant.x][en_passant.y] = 0
		#if play_white && !is_in_check(white_king_pos) || !play_white && !is_in_check(black_king_pos): _moves.append(pos)
		#board[pos.x][pos.y] = 0
		#board[piece_position.x][piece_position.y] = 1 if play_white else -1
		#board[en_passant.x][en_passant.y] = -1 if play_white else 1
	
	var destination_pos = piece_position + direction
	if is_empty(destination_pos) && _get_is_can_move(piece_position, destination_pos):
		_moves.append(destination_pos)
	
	destination_pos = piece_position + Vector2(direction.x, 1)
	if is_valid_position(destination_pos) && is_enemy(destination_pos) && _get_is_can_move(piece_position, destination_pos):
		_moves.append(destination_pos)

	destination_pos = piece_position + Vector2(direction.x, -1)
	if is_valid_position(destination_pos) && is_enemy(destination_pos) && _get_is_can_move(piece_position, destination_pos):
		_moves.append(destination_pos)

	destination_pos = piece_position + direction * 2
	if is_first_move && is_empty(destination_pos) && !is_enemy(destination_pos) && _get_is_can_move(piece_position, destination_pos):
		_moves.append(destination_pos)

	destination_pos = piece_position + direction * 3
	if is_first_move && is_empty(destination_pos) && !is_enemy(destination_pos) && (piece_position.x == 0) && _get_is_can_move(piece_position, destination_pos):
		_moves.append(destination_pos)
	
	return _moves

func _get_is_can_move(piece_position, next_position) -> bool:
	var is_can_move = false
	var t = board[next_position.x][next_position.y]
	var real_piece_code = board[piece_position.x][piece_position.y]
	
	# Try to move
	board[next_position.x][next_position.y] = real_piece_code
	board[piece_position.x][piece_position.y] = 0
	
	# Check if we can move
	if play_white && !is_in_check(white_king_pos) || !play_white && !is_in_check(black_king_pos):
		is_can_move = true
		
	# Move back
	board[next_position.x][next_position.y] = t
	board[piece_position.x][piece_position.y] = real_piece_code
	
	return is_can_move

func is_valid_position(pos : Vector2):
	if pos.x >= 0 && pos.x < BOARD_SIZE && pos.y >= 0 && pos.y < BOARD_SIZE: return true
	return false
	
func is_empty(pos : Vector2):
	if board[pos.x][pos.y] == 0: return true
	return false
	
func is_enemy(pos : Vector2):
	if play_white && board[pos.x][pos.y] < 0 || !play_white && board[pos.x][pos.y] > 0: return true
	return false
	
func promote(_var : Vector2):
	promotion_square = _var
	white_pieces.visible = play_white # Promotion selecting Banner
	black_pieces.visible = !play_white

func _on_button_pressed(button):
	var num_char = int(button.name.substr(0, 1))
	board[promotion_square.x][promotion_square.y] = -num_char if play_white else num_char
	white_pieces.visible = false
	black_pieces.visible = false
	promotion_square = null
	display_board()

func is_in_check(king_pos: Vector2):
	return false
	#var directions = [Vector2(0, 1), Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0),
	#Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]
	#
	#var pawn_direction = 1 if play_white else -1
	#var pawn_attacks = [
		#king_pos + Vector2(pawn_direction, 1),
		#king_pos + Vector2(pawn_direction, -1)
	#]
	#
	#for i in pawn_attacks:
		#if is_valid_position(i):
			#if play_white && board[i.x][i.y] == -1 || !play_white && board[i.x][i.y] == 1: return true
	#
	#for i in directions:
		#var pos = king_pos + i
		#if is_valid_position(pos):
			#if play_white && board[pos.x][pos.y] == -6 || !play_white && board[pos.x][pos.y] == 6: return true
	#
	## Bishop, Queen, Rook
	#for i in directions:
		#var pos = king_pos + i
		#while is_valid_position(pos):
			#if !is_empty(pos):
				#var piece = board[pos.x][pos.y]
				## Rook, Queen
				#if (i.x == 0 || i.y == 0) && (play_white && piece in [-4, -5] || !play_white && piece in [4, 5]):
					#return true
				## Bishop, Queen
				#elif (i.x != 0 && i.y != 0) && (play_white && piece in [-3, -5] || !play_white && piece in [3, 5]):
					#return true
				#break
			#pos += i
	#var knight_directions = [Vector2(2, 1), Vector2(2, -1), Vector2(1, 2), Vector2(1, -2),
	#Vector2(-2, 1), Vector2(-2, -1), Vector2(-1, 2), Vector2(-1, -2)]
	#
	#for i in knight_directions:
		#var pos = king_pos + i
		#if is_valid_position(pos):
			#if play_white && board[pos.x][pos.y] == -2 || !play_white && board[pos.x][pos.y] == 2:
				#return true
				#
	#return false

func is_stalemate():
	if play_white:
		# There is a piece that can still move
		for row in BOARD_SIZE:
			for col in BOARD_SIZE:
				var piece_code = board[row][col]
				if board[row][col] > 0:
					if get_moves(Vector2(row, col), piece_code, piece_code) != []: return false
				
	else:
		for row in BOARD_SIZE:
			for col in BOARD_SIZE:
				var piece_code = board[row][col]
				if board[row][col] < 0:
					if get_moves(Vector2(row, col), piece_code, piece_code) != []: return false
	return true

func insuficient_material():
	var white_piece = 0
	var black_piece = 0
	
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			match board[i][j]:
				2, 3:
					if white_piece == 0: white_piece += 1
					else: return false
				-2, -3:
					if black_piece == 0: black_piece += 1
					else: return false
				6, -6, 0: pass
				_: #4 -4 1 -1 -5 5
					return false
	return true

func threefold_position(var1 : Array):
	for i in unique_board_moves.size():
		if var1 == unique_board_moves[i]:
			amount_of_same[i] += 1
			if amount_of_same[i] >= 3: print("DRAW")
			return
	unique_board_moves.append(var1.duplicate(true))
	amount_of_same.append(1)

func reset_state():
	return "CHOOSE"
	
func get_next_state(state):
	#CHOOSE, BLUFF, MOVE, CHALLENGE, SUCCESS, FAILED
	var next_state = ""
	match state:
		"CHOOSE": next_state = "BLUFF"
		"BLUFF": next_state = "MOVE"
		"MOVE": next_state = reset_state()
		"CHALLENGE": next_state = reset_state()
		"SUCCESS": next_state = reset_state()
		"FAILED": next_state = reset_state()
	print("FROM ",state," TO ",next_state)
	return next_state
	
func _init_zero_array(BOARD_SIZE):
	var empty_array = []
	for i in range(BOARD_SIZE):
		var tmp_array = []
		for j in range(BOARD_SIZE):
			tmp_array.append(0)
		empty_array.append(tmp_array)
	return empty_array

func opponent_king_exist():
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			if((board[row][col] == 6 && !play_white) || (board[row][col] == -6 && play_white)): return true
	return false

func _on_challenge_pressed() -> void:
	if(state != "CHALLENGE"): return
	var peer_id = multiplayer.get_remote_sender_id()
	hidden_board[opponent_dest_pos.x][opponent_dest_pos.y] = 1
	if(abs(opponent_disguise_code) != abs(board[opponent_dest_pos.x][opponent_dest_pos.y])):
		print("CHALLENGE SUCCESS, PLEASE SELECT OPPONENT PIECE TO REVEAL")
		board[opponent_dest_pos.x][opponent_dest_pos.y] = 0
		state = "SUCCESS"
	else:
		print("CHALLENGE FAILED, PLEASE REMOVE ONE OF YOUR PIECE")
		state = "FAILED"
	display_board()
	force_rerender.rpc_id(peer_id, board, hidden_board)

func _on_pawn_selected_pressed() -> void:
	if(state != "BLUFF"): return 
	_handle_disguise(1)
	
func _on_knight_selected_pressed() -> void:
	if(state != "BLUFF"): return 
	_handle_disguise(2)
	
func _on_bishop_selected_pressed() -> void:
	if(state != "BLUFF"): return 
	_handle_disguise(3)
	
func _on_rook_selected_pressed() -> void:
	if(state != "BLUFF"): return 
	_handle_disguise(4)
	
func _on_queen_selected_pressed() -> void:
	if(state != "BLUFF"): return 
	_handle_disguise(5)
	
func _on_king_selected_pressed() -> void:
	if(state != "BLUFF"): return 
	_handle_disguise(6)

func _handle_disguise(input_code):
	disguise_code = input_code
	show_options(selected_piece, disguise_code)
	state = get_next_state(state)
	
func _flip_board(board):
	var new_board = []
	for i in range(BOARD_SIZE - 1,-1, -1):
		var tmp_row = board[i]
		tmp_row.reverse()
		new_board.append(tmp_row)
	return new_board
	
# 0 = empty
# 6 = white king
# 5 = white queen
# 4 = white rook
# 3 = white bishop
# 2 = white knight
# 1 = white pawn


func _on_skip_pressed() -> void:
	state = "CHOOSE"
