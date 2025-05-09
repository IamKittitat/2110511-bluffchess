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

var ENABLED_TIMER_STYLE_BOX = load('res://Assets/common_node_style/timer_enabled_style_box.tres')
var  DISABLED_TIMER_STYLE_BOX = load('res://Assets/common_node_style/timer_disabled_style_box.tres')

@onready var pieces = $Pieces
@onready var dots = $Dots
@onready var turn = $Turn
@onready var white_pieces = $"../CanvasLayer/white_pieces"
@onready var black_pieces = $"../CanvasLayer/black_pieces"

@onready var banner: Control = $"../banner"
@onready var challenge: Panel = $"../banner/challenge"
@onready var challenge_success_out: Panel = $"../banner/challenge_success_out"
@onready var challenge_success_with_icon: Panel = $"../banner/challenge_success_with_icon"
@onready var left_success_icon: TextureRect = $"../banner/challenge_success_with_icon/Left_success_Icon"
@onready var right_success_icon: TextureRect = $"../banner/challenge_success_with_icon/Right_success_Icon"
@onready var challenge_failed_out: Panel = $"../banner/challenge_failed_out"
@onready var challenge_failed_with_icon: Panel = $"../banner/challenge_failed_with_icon"
@onready var left_failed_icon: TextureRect = $"../banner/challenge_failed_with_icon/Left_Icon"
@onready var right_failed_icon: TextureRect = $"../banner/challenge_failed_with_icon/Right_Icon"

@onready var challenge_button: Button = $"../Control/ChallngeContainerBox/ChallengeButton"
@onready var skip_button: Button = $"../Control/ChallngeContainerBox/SkipButton"

@onready var success_panel: Control = $"../sub_banner/success_panel"
@onready var failed_panel: Control = $"../sub_banner/failed_panel"
@onready var sub_banner: Control = $"../sub_banner"

@onready var end_game: Control = $"../End_Game"
@onready var status: Label = $"../End_Game/Status"
@onready var opponent_time: Timer = $"../Control/Opponent_time"
@onready var player_time: Timer = $"../Control/Player_time"
@onready var opponent_timer: Label = $"../Control/Opponent_timer"
@onready var player_timer: Label = $"../Control/Player_timer"

@onready var opponent_eaten: HBoxContainer = $"../Control/Opponent_eaten"
@onready var player_eaten: HBoxContainer = $"../Control/Player_eaten"

@onready var highlight: Node2D = $highlight
const HIGHLIGHT = preload("res://Assets/highlight.png")

@onready var move_sfx_player: AudioStreamPlayer2D = $"../MoveSPXPlayer"
@onready var capture_sfx_player: AudioStreamPlayer2D = $"../CaptureSPXPlayer"

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
var state : String
var moves = []
var selected_piece : Vector2 # x = row, y = col
var disguise_code = 0
var opponent_disguise_code = 0
var opponent_dest_pos: Vector2
var our_eaten_piece: int
var our_eaten_hidden_code: int
var our_eaten_pawn_not_move: int
var is_challenge  = false

func _ready():
	play_white = GlobalScript.play_as == "white"
	opponent_time.wait_time = get_play_phase_int(GlobalScript.play_phase)
	player_time.wait_time = get_play_phase_int(GlobalScript.play_phase)
	opponent_eaten.add_theme_constant_override("seperation",0)
	player_eaten.add_theme_constant_override("seperation",0)
	
	board = GlobalScript.chess_board_data
	hidden_board = GlobalScript.hidden_board_data
	state = "CHOOSE"
	is_my_turn = play_white
	player_time.start()
	opponent_time.start()
	_swap_timer()
	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			if row <= 1:
				pawn_not_moved[row][col] = 1
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
	#if event is InputEventMouseButton and event.pressed and banner.visible:
		#close_banner()
	if event is InputEventMouseButton && event.pressed:
		if (!our_king_exist()) or (!opponent_king_exist()): return
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_mouse_out(): return
			if !is_my_turn: return
			
			var col = snapped(get_global_mouse_position().x, 0) / CELL_WIDTH # Find index on the board
			var row = abs(snapped(get_global_mouse_position().y, 0)) / CELL_WIDTH
			# Select pieces to move
			if state == "CHOOSE" && (play_white && board[row][col] > 0 || !play_white && board[row][col] < 0):
				opponent_disguise_code = 0
				selected_piece = Vector2(row, col)
				delete_highlight()
				show_highlight(row,col)
				if(hidden_board[row][col] == 2):
					state = get_next_state(state)
				else:
					show_options(selected_piece, abs(board[row][col]))
					state = "MOVE"
			# Select pieces to disguise.
			elif state == "BLUFF":
				state= reset_state() # If click anywhere in the board (Not click on the bluff button), reset state
				delete_highlight()
			elif state == "MOVE": 
				set_move(row, col)
				disguise_code = 0
				state = reset_state()
			elif state == "SUCCESS":
				if(!_is_opponent_hidden_exist()): # If no hidden piece left > cant reveal any.
					state = get_next_state(state)
					close_banner.rpc()
				if((play_white && board[row][col] < 0) || (!play_white && board[row][col] > 0)):
					if(hidden_board[row][col] == 2):
						hidden_board[row][col] = 1
						state = get_next_state(state)
						close_banner.rpc()
						display_board()
						display_eaten_piece.rpc()
						force_rerender.rpc_id(peer_id, board, hidden_board)
			elif state == "FAILED":
				if((play_white && board[row][col] > 0) || (!play_white && board[row][col] < 0)):
					board[row][col] = 0
					pawn_not_moved[row][col] = 0
					state = get_next_state(state)
					close_banner.rpc()
					display_board()
					display_eaten_piece.rpc()
					force_rerender.rpc_id(peer_id, board, hidden_board)
					_check_loss()
	
				
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
				if(opponent_disguise_code != 0 && row == opponent_dest_pos.x && col == opponent_dest_pos.y):
					match abs(opponent_disguise_code):
						6: holder.texture = WHITE_HIDDEN_KING
						5: holder.texture = WHITE_HIDDEN_QUEEN
						4: holder.texture = WHITE_HIDDEN_ROOK
						3: holder.texture = WHITE_HIDDEN_BISHOP
						2: holder.texture = WHITE_HIDDEN_KNIGHT
						1: holder.texture = WHITE_HIDDEN_PAWN
				elif(hidden_board[row][col] == 1):
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
				if(opponent_disguise_code != 0 && row == opponent_dest_pos.x && col == opponent_dest_pos.y):
					match abs(opponent_disguise_code):
						6: holder.texture = BLACK_HIDDEN_KING
						5: holder.texture = BLACK_HIDDEN_QUEEN
						4: holder.texture = BLACK_HIDDEN_ROOK
						3: holder.texture = BLACK_HIDDEN_BISHOP
						2: holder.texture = BLACK_HIDDEN_KNIGHT
						1: holder.texture = BLACK_HIDDEN_PAWN
				elif(hidden_board[row][col] == 1):
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

@rpc("any_peer", "call_local", "reliable")	
func display_eaten_piece():
	#eaten zone
	var starting_white = [1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,2, 2, 3, 3, 4, 4, 5, 6]
	var starting_black = [-1 ,-1 ,-1 ,-1 ,-1 ,-1 ,-1 ,-1 ,-2, -2, -3, -3, -4, -4, -5, -6]
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			if(board[row][col] > 0):
				starting_white.erase(board[row][col])
			elif(board[row][col] < 0):
				starting_black.erase(board[row][col])
	for child in opponent_eaten.get_children():
		child.queue_free()
	for child in player_eaten.get_children():
		child.queue_free()
	if play_white:
		for i in range(starting_white.size()):
			var margin = MarginContainer.new()
			if i > 0:
				if starting_white[i] != starting_white[i-1]:
					margin.add_theme_constant_override("margin_left", -6)
				else:
					margin.add_theme_constant_override("margin_left", -12)
			var tex_rect = TextureRect.new()
			match starting_white[i]:
				6: tex_rect.texture = WHITE_PAWN
				5: tex_rect.texture = WHITE_QUEEN
				4: tex_rect.texture = WHITE_ROOK
				3: tex_rect.texture = WHITE_BISHOP
				2: tex_rect.texture = WHITE_KNIGHT
				1: tex_rect.texture = WHITE_PAWN
			tex_rect.custom_minimum_size = Vector2(12, 12) 
			tex_rect.expand = true
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			margin.add_child(tex_rect)
			player_eaten.add_child(margin)
		for i in range(starting_black.size()):
			var margin = MarginContainer.new()
			if i > 0:
				if starting_black[i] != starting_black[i-1]:
					margin.add_theme_constant_override("margin_left", -6)
				else:
					margin.add_theme_constant_override("margin_left", -12)
			var tex_rect = TextureRect.new()
			match starting_black[i]:
				-6: tex_rect.texture = BLACK_PAWN
				-5: tex_rect.texture = BLACK_QUEEN
				-4: tex_rect.texture = BLACK_ROOK
				-3: tex_rect.texture = BLACK_BISHOP
				-2: tex_rect.texture = BLACK_KNIGHT
				-1: tex_rect.texture = BLACK_PAWN
			tex_rect.custom_minimum_size = Vector2(12, 12) 
			tex_rect.expand = true
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			margin.add_child(tex_rect)
			opponent_eaten.add_child(margin)
	else:
		for i in range(starting_white.size()):
			var margin = MarginContainer.new()
			if i > 0:
				if starting_white[i] != starting_white[i-1]:
					margin.add_theme_constant_override("margin_left", -6)
				else:
					margin.add_theme_constant_override("margin_left", -12)
			var tex_rect = TextureRect.new()
			match starting_white[i]:
				6: tex_rect.texture = WHITE_PAWN
				5: tex_rect.texture = WHITE_QUEEN
				4: tex_rect.texture = WHITE_ROOK
				3: tex_rect.texture = WHITE_BISHOP
				2: tex_rect.texture = WHITE_KNIGHT
				1: tex_rect.texture = WHITE_PAWN
			tex_rect.custom_minimum_size = Vector2(12, 12) 
			tex_rect.expand = true
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			margin.add_child(tex_rect)
			opponent_eaten.add_child(margin)
		for i in range(starting_black.size()):
			var margin = MarginContainer.new()
			if i > 0:
				if starting_black[i] != starting_black[i-1]:
					margin.add_theme_constant_override("margin_left", -6)
				else:
					margin.add_theme_constant_override("margin_left", -12)
			var tex_rect = TextureRect.new()
			match starting_black[i]:
				-6: tex_rect.texture = BLACK_PAWN
				-5: tex_rect.texture = BLACK_QUEEN
				-4: tex_rect.texture = BLACK_ROOK
				-3: tex_rect.texture = BLACK_BISHOP
				-2: tex_rect.texture = BLACK_KNIGHT
				-1: tex_rect.texture = BLACK_PAWN
			tex_rect.custom_minimum_size = Vector2(12, 12) 
			tex_rect.expand = true
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			margin.add_child(tex_rect)
			player_eaten.add_child(margin)
	
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
	for i in moves:
		if i.x == row && i.y == col:
			var eaten_piece
			eaten_piece = _move(selected_piece, row, col)
			is_my_turn = !is_my_turn
			_swap_timer()
			display_board()
			
			if eaten_piece[0] == 0:
				move_sfx_player.play()
			else:
				capture_sfx_player.play()
			
			handle_opponent_move.rpc_id(peer_id, board, hidden_board, row, col, disguise_code, eaten_piece[0], eaten_piece[1])
			break
			
	delete_dots()
	delete_highlight()
	state = reset_state()
	if(GlobalScript.play_phase == "15|10"):
		var time_left = player_time.time_left
		player_time.start(time_left + 10)
		plus_10_timer.rpc_id(peer_id, time_left)
	
@rpc("any_peer", "call_remote", "reliable")	
func plus_10_timer(time_left):
	opponent_time.start(time_left + 10)
		
func _move(selected_piece, row, col):
	var eaten_piece = board[row][col]
	var eaten_hidden_code = hidden_board[row][col]
	board[row][col] = board[selected_piece.x][selected_piece.y]
	hidden_board[row][col] = hidden_board[selected_piece.x][selected_piece.y]
	board[selected_piece.x][selected_piece.y] = 0
	hidden_board[selected_piece.x][selected_piece.y] = 0
	pawn_not_moved[row][col] = 0
	return [eaten_piece, eaten_hidden_code]

func self_handle_game_loss():
	status.text = "You Lose!"
	player_time.stop()
	opponent_time.stop()
	end_game.visible = true
	

func self_handle_game_win():
	status.text = "You Win!"
	player_time.stop()
	opponent_time.stop()
	end_game.visible = true
	
@rpc("any_peer", "call_remote", "reliable")
func handle_opponent_move(opponent_board, opponent_hidden_board, dest_row, dest_col, disguise_code, eaten_piece, eaten_hidden_code):
	var peer_id = multiplayer.get_remote_sender_id()
	is_challenge = false
	opponent_disguise_code = disguise_code
	dest_row = BOARD_SIZE - dest_row - 1
	dest_col = BOARD_SIZE - dest_col - 1
	our_eaten_piece = eaten_piece
	our_eaten_hidden_code = eaten_hidden_code
	our_eaten_pawn_not_move = pawn_not_moved[dest_row][dest_col]
	opponent_dest_pos = Vector2(dest_row, dest_col)
	board = _flip_board(opponent_board)
	hidden_board = _flip_board(opponent_hidden_board)
	pawn_not_moved[dest_row][dest_col] = 0
	
	if eaten_piece == 0:
		move_sfx_player.play()
	else:
		capture_sfx_player.play()
	
	if(hidden_board[dest_row][dest_col] == 2):
		state = "CHALLENGE"
	else:
		state = "CHOOSE"
		_check_loss()
	
	is_my_turn = !is_my_turn
	_swap_timer()
	display_board()
	
	if(hidden_board[dest_row][dest_col] == 2):
		_set_challenge_button_group(false)	
		await get_tree().create_timer(5.0).timeout
		_set_challenge_button_group(true)
		
		if(state == "CHALLENGE" && !is_challenge):
			_check_loss()
			state = "CHOOSE"
			display_board()
			display_eaten_piece.rpc()

func _set_challenge_button_group(disabled: bool):
	challenge_button.disabled = disabled
	skip_button.disabled = disabled
	if(disabled):
		challenge_button.mouse_filter =Control.MOUSE_FILTER_IGNORE
		skip_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		challenge_button.mouse_filter =Control.MOUSE_FILTER_PASS
		skip_button.mouse_filter = Control.MOUSE_FILTER_PASS
		
	challenge_button.release_focus()
	skip_button.release_focus()
	
@rpc("any_peer", "call_remote", "reliable")	
func force_rerender(opponent_board, opponent_hidden_board):
	board = _flip_board(opponent_board)
	hidden_board = _flip_board(opponent_hidden_board)
	display_board()
	display_eaten_piece.rpc()
	
@rpc("any_peer", "call_remote", "reliable")
func opponent_handle_game_win():
	status.text = "You Win!"
	player_time.stop()
	opponent_time.stop()
	end_game.visible = true

@rpc("any_peer", "call_remote", "reliable")
func opponent_handle_game_loss():
	status.text = "You Lose!"
	player_time.stop()
	opponent_time.stop()
	end_game.visible = true
		
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
				_moves.append(destination_pos)
			elif is_enemy(destination_pos):
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
				_moves.append(destination_pos)
			elif is_enemy(destination_pos):
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
				_moves.append(destination_pos)
			elif is_enemy(destination_pos):
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
	
	for i in directions:
		var destination_pos = piece_position + i
		if is_valid_position(destination_pos):
			if is_empty(destination_pos) || is_enemy(destination_pos):
				_moves.append(destination_pos)
				
	return _moves
	
func get_knight_moves(piece_position : Vector2):
	var _moves = []
	var directions = [Vector2(2, 1), Vector2(2, -1), Vector2(1, 2), Vector2(1, -2),
	Vector2(-2, 1), Vector2(-2, -1), Vector2(-1, 2), Vector2(-1, -2)]
	
	for i in directions:
		var destination_pos = piece_position + i
		if is_valid_position(destination_pos):
			if is_empty(destination_pos) || is_enemy(destination_pos):
				_moves.append(destination_pos)
	
	return _moves

func get_pawn_moves(piece_position : Vector2):
	var _moves = []
	var direction
	var is_first_move = pawn_not_moved[piece_position.x][piece_position.y] == 1
	direction = Vector2(1, 0)

	var destination_pos = piece_position + direction
	if is_empty(destination_pos):
		_moves.append(destination_pos)
	
	destination_pos = piece_position + Vector2(direction.x, 1)
	if is_valid_position(destination_pos) && is_enemy(destination_pos):
		_moves.append(destination_pos)

	destination_pos = piece_position + Vector2(direction.x, -1)
	if is_valid_position(destination_pos) && is_enemy(destination_pos):
		_moves.append(destination_pos)

	var front_pos_1 = piece_position + direction
	var front_pos_2 = piece_position + direction * 2
	destination_pos = piece_position + direction * 2
	
	if is_first_move && is_empty(destination_pos) && is_empty(front_pos_1):
		_moves.append(destination_pos)

	destination_pos = piece_position + direction * 3
	if is_first_move && is_empty(destination_pos) && is_empty(front_pos_1) && is_empty(front_pos_2) && (piece_position.x == 0):
		_moves.append(destination_pos)
	
	return _moves

func is_valid_position(pos : Vector2):
	if pos.x >= 0 && pos.x < BOARD_SIZE && pos.y >= 0 && pos.y < BOARD_SIZE: return true
	return false
	
func is_empty(pos : Vector2):
	if board[pos.x][pos.y] == 0: return true
	return false
	
func is_enemy(pos : Vector2):
	if play_white && board[pos.x][pos.y] < 0 || !play_white && board[pos.x][pos.y] > 0: return true
	return false
	
func _on_button_pressed(button):
	var num_char = int(button.name.substr(0, 1))
	white_pieces.visible = false
	black_pieces.visible = false
	display_board()
	display_eaten_piece.rpc()

func reset_state():
	return "CHOOSE"
	
func get_next_state(state):
	# CHOOSE, BLUFF, MOVE, CHALLENGE, SUCCESS, FAILED
	var next_state = ""
	match state:
		"CHOOSE": next_state = "BLUFF"
		"BLUFF": next_state = "MOVE"
		"MOVE": next_state = reset_state()
		"CHALLENGE": next_state = reset_state()
		"SUCCESS": next_state = reset_state()
		"FAILED": next_state = reset_state()
	return next_state
	
func _init_zero_array(BOARD_SIZE):
	var empty_array = []
	for i in range(BOARD_SIZE):
		var tmp_array = []
		for j in range(BOARD_SIZE):
			tmp_array.append(0)
		empty_array.append(tmp_array)
	return empty_array

func our_king_exist():
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			if((board[row][col] == 6 && play_white) || (board[row][col] == -6 && !play_white)): return true
	return false

func opponent_king_exist():
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			if((board[row][col] == 6 && !play_white) || (board[row][col] == -6 && play_white)): return true
	return false
	
func _on_challenge_pressed() -> void:
	is_challenge = true
	if(state != "CHALLENGE"): return
	var peer_id = multiplayer.get_remote_sender_id()
	hidden_board[opponent_dest_pos.x][opponent_dest_pos.y] = 1
	show_challenge_banner.rpc()
	await get_tree().create_timer(2.0).timeout
	if(abs(opponent_disguise_code) != abs(board[opponent_dest_pos.x][opponent_dest_pos.y])):
		close_banner.rpc()
		show_challenge_success_banner.rpc(opponent_disguise_code,board[opponent_dest_pos.x][opponent_dest_pos.y])
		await get_tree().create_timer(2.0).timeout
		close_banner.rpc()
		show_challenge_success_out_banner.rpc_id(peer_id)
		show_success_sub_banner()
		opponent_disguise_code = 0
		
		# Undo the move
		board[opponent_dest_pos.x][opponent_dest_pos.y] = our_eaten_piece
		hidden_board[opponent_dest_pos.x][opponent_dest_pos.y] = our_eaten_hidden_code
		pawn_not_moved[opponent_dest_pos.x][opponent_dest_pos.y] = our_eaten_pawn_not_move
		
		state = "SUCCESS"
		_check_win() # incase of opponent use king to bluff and got challenged --> King will be removed from the game
	else:
		close_banner.rpc()
		show_challenge_failed_banner.rpc(opponent_disguise_code,board[opponent_dest_pos.x][opponent_dest_pos.y])
		await get_tree().create_timer(2.0).timeout
		close_banner.rpc()
		show_challenge_failed_out_banner.rpc_id(peer_id)
		show_failed_sub_banner()
		
		opponent_disguise_code = 0
		hidden_board[opponent_dest_pos.x][opponent_dest_pos.y] = 1
		state = "FAILED"
	display_board()
	display_eaten_piece.rpc()
	force_rerender.rpc_id(peer_id, board, hidden_board)
	await get_tree().create_timer(0.1).timeout

func _on_pawn_selected_pressed() -> void:
	if(state in ["BLUFF", "MOVE"] && hidden_board[selected_piece.x][selected_piece.y] == 2):
		_handle_disguise(1)
	
func _on_knight_selected_pressed() -> void:
	if(state in ["BLUFF", "MOVE"] && hidden_board[selected_piece.x][selected_piece.y] == 2):
		_handle_disguise(2)
	
func _on_bishop_selected_pressed() -> void:
	if(state in ["BLUFF", "MOVE"] && hidden_board[selected_piece.x][selected_piece.y] == 2):
		_handle_disguise(3)
	
func _on_rook_selected_pressed() -> void:
	if(state in ["BLUFF", "MOVE"] && hidden_board[selected_piece.x][selected_piece.y] == 2):
		_handle_disguise(4)
	
func _on_queen_selected_pressed() -> void:
	if(state in ["BLUFF", "MOVE"] && hidden_board[selected_piece.x][selected_piece.y] == 2):
		_handle_disguise(5)
	
func _on_king_selected_pressed() -> void:
	if(state in ["BLUFF", "MOVE"] && hidden_board[selected_piece.x][selected_piece.y] == 2):
		_handle_disguise(6)

func _handle_disguise(input_code):
	delete_dots()
	disguise_code = input_code
	show_options(selected_piece, disguise_code)
	state = "MOVE"
	
func _flip_board(board):
	var new_board = []
	for i in range(BOARD_SIZE - 1,-1, -1):
		var tmp_row = board[i]
		tmp_row.reverse()
		new_board.append(tmp_row)
	return new_board
	
func _check_loss():
	var peer_id = multiplayer.get_remote_sender_id()
	if(!our_king_exist()):
		self_handle_game_loss()
		opponent_handle_game_win.rpc_id(peer_id)
		
func _check_win():
	var peer_id = multiplayer.get_remote_sender_id()
	if(!opponent_king_exist()):
		self_handle_game_win()
		opponent_handle_game_loss.rpc_id(peer_id)
	
func _on_skip_pressed() -> void:
	state = "CHOOSE"
	_set_challenge_button_group(true)
	_check_loss()
	display_board()
	display_eaten_piece.rpc()
	
#close banner
@rpc("any_peer", "call_local", "reliable")	
func close_banner():	
	banner.visible = false
	challenge.visible = false
	challenge_success_out.visible = false
	challenge_success_with_icon.visible = false
	challenge_failed_out.visible = false
	challenge_failed_with_icon.visible = false
	sub_banner.visible = false
	success_panel.visible = false
	failed_panel.visible = false
	
	
#show banner
@rpc("any_peer", "call_local", "reliable")	
func show_challenge_banner():
	banner.visible = true
	challenge.visible = true
	
@rpc("any_peer", "call_local", "reliable")	
func show_challenge_success_banner(disguise,real):
	if(real < 0):
		disguise = -disguise
	match disguise:
		6: left_success_icon.texture = WHITE_HIDDEN_KING
		5: left_success_icon.texture = WHITE_HIDDEN_QUEEN
		4: left_success_icon.texture = WHITE_HIDDEN_ROOK
		3: left_success_icon.texture = WHITE_HIDDEN_BISHOP
		2: left_success_icon.texture = WHITE_HIDDEN_KNIGHT
		1: left_success_icon.texture = WHITE_HIDDEN_PAWN
		-6: left_success_icon.texture = BLACK_HIDDEN_KING
		-5: left_success_icon.texture = BLACK_HIDDEN_QUEEN
		-4: left_success_icon.texture = BLACK_HIDDEN_ROOK
		-3: left_success_icon.texture = BLACK_HIDDEN_BISHOP
		-2: left_success_icon.texture = BLACK_HIDDEN_KNIGHT
		-1: left_success_icon.texture = BLACK_HIDDEN_PAWN
	match real:
		6: right_success_icon.texture = WHITE_KING
		5: right_success_icon.texture = WHITE_QUEEN
		4: right_success_icon.texture = WHITE_ROOK
		3: right_success_icon.texture = WHITE_BISHOP
		2: right_success_icon.texture = WHITE_KNIGHT
		1: right_success_icon.texture = WHITE_PAWN
		-6: right_success_icon.texture = BLACK_KING
		-5: right_success_icon.texture = BLACK_QUEEN
		-4: right_success_icon.texture = BLACK_ROOK
		-3: right_success_icon.texture = BLACK_BISHOP
		-2: right_success_icon.texture = BLACK_KNIGHT
		-1: right_success_icon.texture = BLACK_PAWN
	banner.visible = true
	challenge_success_with_icon.visible = true
	
@rpc("any_peer", "call_local", "reliable")	
func show_challenge_failed_banner(disguise,real):
	if(real < 0):
		disguise = -disguise
	match disguise:
		6: left_failed_icon.texture = WHITE_HIDDEN_KING
		5: left_failed_icon.texture = WHITE_HIDDEN_QUEEN
		4: left_failed_icon.texture = WHITE_HIDDEN_ROOK
		3: left_failed_icon.texture = WHITE_HIDDEN_BISHOP
		2: left_failed_icon.texture = WHITE_HIDDEN_KNIGHT
		1: left_failed_icon.texture = WHITE_HIDDEN_PAWN
		-6: left_failed_icon.texture = BLACK_HIDDEN_KING
		-5: left_failed_icon.texture = BLACK_HIDDEN_QUEEN
		-4: left_failed_icon.texture = BLACK_HIDDEN_ROOK
		-3: left_failed_icon.texture = BLACK_HIDDEN_BISHOP
		-2: left_failed_icon.texture = BLACK_HIDDEN_KNIGHT
		-1: left_failed_icon.texture = BLACK_HIDDEN_PAWN
	match real:
		6: right_failed_icon.texture = WHITE_KING
		5: right_failed_icon.texture = WHITE_QUEEN
		4: right_failed_icon.texture = WHITE_ROOK
		3: right_failed_icon.texture = WHITE_BISHOP
		2: right_failed_icon.texture = WHITE_KNIGHT
		1: right_failed_icon.texture = WHITE_PAWN
		-6: right_failed_icon.texture = BLACK_KING
		-5: right_failed_icon.texture = BLACK_QUEEN
		-4: right_failed_icon.texture = BLACK_ROOK
		-3: right_failed_icon.texture = BLACK_BISHOP
		-2: right_failed_icon.texture = BLACK_KNIGHT
		-1: right_failed_icon.texture = BLACK_PAWN
	banner.visible = true
	challenge_failed_with_icon.visible = true
	
@rpc("any_peer","call_remote","reliable")
func show_challenge_success_out_banner():
	banner.visible = true
	challenge_success_out.visible = true
	
@rpc("any_peer","call_remote","reliable")
func show_challenge_failed_out_banner():
	banner.visible = true
	challenge_failed_out.visible = true
	
func show_success_sub_banner():
	sub_banner.visible = true
	success_panel.visible = true
	
func show_failed_sub_banner():
	sub_banner.visible = true
	failed_panel.visible = true
	
func _on_back_to_menu_pressed():
	end_game.visible = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func time_left_to_live():
	var total_player_sec = int(player_time.time_left)
	var player_minute = total_player_sec / 60
	var player_second = total_player_sec % 60
	var total_opponent_sec = int(opponent_time.time_left)
	var opponent_minute = total_opponent_sec / 60
	var opponent_second = total_opponent_sec % 60
	return [player_minute, player_second, opponent_minute, opponent_second]

func _swap_timer():
	player_time.set_paused(not is_my_turn)
	opponent_time.set_paused(is_my_turn)
	
	# Render timer
	if is_my_turn:
		player_timer.add_theme_stylebox_override("normal", ENABLED_TIMER_STYLE_BOX)
		player_timer.add_theme_color_override("font_color", '#383838')
		opponent_timer.add_theme_stylebox_override("normal", DISABLED_TIMER_STYLE_BOX)
		opponent_timer.add_theme_color_override("font_color", '#FFFFFF')
	else:
		player_timer.add_theme_stylebox_override("normal", DISABLED_TIMER_STYLE_BOX)
		player_timer.add_theme_color_override("font_color", '#FFFFFF')
		opponent_timer.add_theme_stylebox_override("normal", ENABLED_TIMER_STYLE_BOX)
		opponent_timer.add_theme_color_override("font_color", '#383838')
	

func _process(delta):
	var peer_id = multiplayer.get_remote_sender_id()
	opponent_timer.text = "%02d:%02d" % [time_left_to_live()[2],time_left_to_live()[3]]
	player_timer.text = "%02d:%02d" % [time_left_to_live()[0],time_left_to_live()[1]]
	
	# Only check for timer 
	if(int(player_time.time_left) == 0 && our_king_exist() && opponent_king_exist()):
		self_handle_game_loss()
		opponent_handle_game_win.rpc_id(peer_id)
	
func show_highlight(x,y):
	var holder = TEXTURE_HOLDER.instantiate()
	holder.texture = HIGHLIGHT		
	holder.scale = Vector2(18.0 / holder.texture.get_width(), 18.0 / holder.texture.get_height())
	holder.global_position = Vector2(y * CELL_WIDTH + (CELL_WIDTH / 2) - 72, - x * CELL_WIDTH - (CELL_WIDTH / 2) + 72)
	highlight.add_child(holder)

func delete_highlight():
	for child in highlight.get_children():
		child.queue_free()

func _is_opponent_hidden_exist():
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			if((play_white && board[row][col] < 0 && hidden_board[row][col] == 2) || (!play_white && board[row][col] > 0 && hidden_board[row][col] == 2)):
				return true
	return false

func get_play_phase_int(play_phase):
	if(play_phase == "10 min"):
		return 600
	elif(play_phase == "15|10"):
		return 900
	elif(play_phase == "30 min"):
		return 1800
