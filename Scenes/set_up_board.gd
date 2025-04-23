extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 60

const TEXTURE_HOLDER_SETUP = preload("res://Scenes/texture_holder_setup.tscn")

const BLACK_HIDDEN_BISHOP = preload("res://Assets/Piece/black_hidden_bishop.png")
const BLACK_HIDDEN_KING = preload("res://Assets/Piece/black_hidden_king.png")
const BLACK_HIDDEN_KNIGHT = preload("res://Assets/Piece/black_hidden_knight.png")
const BLACK_HIDDEN_PAWN = preload("res://Assets/Piece/black_hidden_pawn.png")
const BLACK_HIDDEN_QUEEN = preload("res://Assets/Piece/black_hidden_queen.png")
const BLACK_HIDDEN_ROOK = preload("res://Assets/Piece/black_hidden_rook.png")
const BLACK_HIDDEN = preload("res://Assets/Piece/black_hidden.png")
const WHITE_HIDDEN_BISHOP = preload("res://Assets/Piece/white_hidden_bishop.png")
const WHITE_HIDDEN_KING = preload("res://Assets/Piece/white_hidden_king.png")
const WHITE_HIDDEN_KNIGHT = preload("res://Assets/Piece/white_hidden_knight.png")
const WHITE_HIDDEN_PAWN = preload("res://Assets/Piece/white_hidden_pawn.png")
const WHITE_HIDDEN_QUEEN = preload("res://Assets/Piece/white_hidden_queen.png")
const WHITE_HIDDEN_ROOK = preload("res://Assets/Piece/white_hidden_rook.png")
const WHITE_HIDDEN = preload("res://Assets/Piece/white_hidden.png")

@onready var pieces: Node2D = $Pieces

@onready var timer: Timer = $"../Timer"
@onready var timer_label: Label = $"../Select/Timer"

@onready var king_texture: TextureRect = $"../Select/VBoxContainer/king_select/king_texture"
@onready var queen_texture: TextureRect = $"../Select/VBoxContainer/queen_select/queen_texture"
@onready var knight_texture: TextureRect = $"../Select/VBoxContainer/knight_select/knight_texture"
@onready var bishop_texture: TextureRect = $"../Select/VBoxContainer/bishop_select/bishop_texture"
@onready var rook_texture: TextureRect = $"../Select/VBoxContainer/rook_select/rook_texture"
@onready var pawn_texture: TextureRect = $"../Select/VBoxContainer/pawn_select/pawn_texture"

@onready var king_select: Button = $"../Select/VBoxContainer/king_select"
@onready var queen_select: Button = $"../Select/VBoxContainer/queen_select"
@onready var knight_select: Button = $"../Select/VBoxContainer/knight_select"
@onready var bishop_select: Button = $"../Select/VBoxContainer/bishop_select"
@onready var rook_select: Button = $"../Select/VBoxContainer/rook_select"
@onready var pawn_select: Button = $"../Select/VBoxContainer/pawn_select"

@onready var delete_mode: CheckButton = $"../Select/DeleteMode"

@onready var ready_button: Button = $"../ReadyButton"

var board
var hidden_board
var another_board
var is_my_turn
var play_white
var selected_piece
var piece_left
var another_ready
var iam_ready
var is_delete
	
func _ready():
	_init_parameter()
	
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	
	######################### MOCK ZONE	#########################
	#board = []
	#if(play_white):
		#board.append([2, 2, 3, 3, 4, 4, 5, 6])
		#board.append([1, 1, 1, 1, 1, 1, 1, 1])
	#else:
		#board.append([-2, -2, -3, -3, -4, -4, -5, -6])
		#board.append([-1, -1, -1, -1, -1, -1, -1, -1])
	#board.append([0, 0, 0, 0, 0, 0, 0, 0])
	#board.append([0, 0, 0, 0, 0, 0, 0, 0])
	#board.append([0, 0, 0, 0, 0, 0, 0, 0])
	#board.append([0, 0, 0, 0, 0, 0, 0, 0])
	#board.append([-1, -1, -1, -1, -1, -1, -1, -1])
	#board.append([-2, -2, -3, -3, -4, -4, -5, -6])
	#piece_left = [0,0,0,0,0,0,0]
	##############################################################
	
	hidden_board.append([2, 2, 2, 2, 2, 2, 2, 2])
	hidden_board.append([2, 2, 2, 2, 2, 2, 2, 2])
	hidden_board.append([0, 0, 0, 0, 0, 0, 0, 0])
	hidden_board.append([0, 0, 0, 0, 0, 0, 0, 0])
	hidden_board.append([0, 0, 0, 0, 0, 0, 0, 0])
	hidden_board.append([0, 0, 0, 0, 0, 0, 0, 0])
	hidden_board.append([2, 2, 2, 2, 2, 2, 2, 2])
	hidden_board.append([2, 2, 2, 2, 2, 2, 2, 2])
	
	if(!play_white):
		king_texture.texture = BLACK_HIDDEN_KING
		queen_texture.texture = BLACK_HIDDEN_QUEEN
		knight_texture.texture = BLACK_HIDDEN_KNIGHT
		bishop_texture.texture = BLACK_HIDDEN_BISHOP
		rook_texture.texture = BLACK_HIDDEN_ROOK
		pawn_texture.texture = BLACK_HIDDEN_PAWN
	
	display_board()
	
func display_board():
	for child in pieces.get_children():
		child.queue_free()
		
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			var holder = TEXTURE_HOLDER_SETUP.instantiate()
			pieces.add_child(holder)
			holder.global_position = Vector2(col * CELL_WIDTH + (CELL_WIDTH / 2) + 112, - row * CELL_WIDTH + (CELL_WIDTH / 2) + 500)
			
			if(row <= 1):
				if(play_white):
					match board[row][col]:
						6: holder.texture = WHITE_HIDDEN_KING
						5: holder.texture = WHITE_HIDDEN_QUEEN
						4: holder.texture = WHITE_HIDDEN_ROOK
						3: holder.texture = WHITE_HIDDEN_BISHOP
						2: holder.texture = WHITE_HIDDEN_KNIGHT
						1: holder.texture = WHITE_HIDDEN_PAWN
				else:
					match board[row][col]:
						-6: holder.texture = BLACK_HIDDEN_KING
						-5: holder.texture = BLACK_HIDDEN_QUEEN
						-4: holder.texture = BLACK_HIDDEN_ROOK
						-3: holder.texture = BLACK_HIDDEN_BISHOP
						-2: holder.texture = BLACK_HIDDEN_KNIGHT
						-1: holder.texture = BLACK_HIDDEN_PAWN
			elif(row >= 6):
				if(play_white):
					holder.texture = BLACK_HIDDEN
				else:
					holder.texture = WHITE_HIDDEN
			else:
				holder.texture = null
					
			holder.scale = Vector2(0.25, 0.25)

func _input(event):
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_mouse_out(): return
			var col = snapped(get_global_mouse_position().x - 112, 0) / CELL_WIDTH
			var row = abs(snapped(get_global_mouse_position().y - 560.6, 0)) / CELL_WIDTH
			
			if(row < 0 || row > 7 || col < 0 || col > 7): return
			if(row <= 1):
				if(is_delete):
					if(board[row][col] != 0): piece_left[abs(board[row][col])] += 1
					match abs(board[row][col]):
						6: king_select.text = "%d pieces  " % piece_left[abs(board[row][col])]
						5: queen_select.text = "%d pieces  " % piece_left[abs(board[row][col])]
						2: knight_select.text = "%d pieces  " % piece_left[abs(board[row][col])]
						3: bishop_select.text = "%d pieces  " % piece_left[abs(board[row][col])]
						4: rook_select.text = "%d pieces  " % piece_left[abs(board[row][col])]
						1: pawn_select.text = "%d pieces  " % piece_left[abs(board[row][col])]
					board[row][col] = 0
				else:
					# No more piece left to place
					if(piece_left[abs(selected_piece)] == 0): return
					
					# Paste the piece over another placed piece
					if(board[row][col] != 0): piece_left[abs(board[row][col])] += 1
					
					match abs(board[row][col]):
						6: king_select.text = "%d pieces  " % piece_left[abs(board[row][col])]
						5: queen_select.text = "%d pieces  " % piece_left[abs(board[row][col])]
						2: knight_select.text = "%d pieces  " % piece_left[abs(board[row][col])]
						3: bishop_select.text = "%d pieces  " % piece_left[abs(board[row][col])]
						4: rook_select.text = "%d pieces  " % piece_left[abs(board[row][col])]
						1: pawn_select.text = "%d pieces  " % piece_left[abs(board[row][col])]
						
					board[row][col] = selected_piece
					piece_left[abs(selected_piece)] -= 1
					
					match abs(selected_piece):
						6: king_select.text = "%d pieces  " % piece_left[abs(selected_piece)]
						5: queen_select.text = "%d pieces  " % piece_left[abs(selected_piece)]
						2: knight_select.text = "%d pieces  " % piece_left[abs(selected_piece)]
						3: bishop_select.text = "%d pieces  " % piece_left[abs(selected_piece)]
						4: rook_select.text = "%d pieces  " % piece_left[abs(selected_piece)]
						1: pawn_select.text = "%d pieces  " % piece_left[abs(selected_piece)]
					
					if(piece_left[abs(selected_piece)] == 0): selected_piece = 0
				display_board()
				_check_is_button_2_disabled()
			
func is_mouse_out():
	if get_rect().has_point(to_local(get_global_mouse_position())): return false
	return true

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_button_2_pressed() -> void:
	var peer_id = multiplayer.get_remote_sender_id()
	GlobalScript.chess_board_data = board
	GlobalScript.hidden_board_data = hidden_board
	iam_ready = true
	trigger_ready.rpc_id(peer_id, board)

func _check_is_button_2_disabled(): 
	for x in piece_left:
		if x > 0: 
			ready_button.disabled = true
			ready_button.mouse_filter =Control.MOUSE_FILTER_IGNORE
			return 
	
	ready_button.disabled = false
	ready_button.mouse_filter =Control.MOUSE_FILTER_PASS

@rpc("any_peer", "call_remote", "reliable")
func trigger_ready(board):
	another_ready = true
	another_board = board
	if(iam_ready):
		combined_board.rpc()
		

@rpc("any_peer", "call_local", "reliable")	
func combined_board():
	var new_board = []
	for row in BOARD_SIZE:
		var col_board = GlobalScript.chess_board_data[row]
		if row >= 6:
			col_board = another_board[BOARD_SIZE - row - 1]
			col_board.reverse()
		new_board.append(col_board)
	
	GlobalScript.chess_board_data = new_board	
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_king_button_pressed() -> void:
	if(piece_left[6] == 0): 
		selected_piece = 0
	else:
		selected_piece = 6 if play_white else -6

func _on_queen_button_pressed() -> void:
	if(piece_left[5] == 0): 
		selected_piece = 0
	else:
		selected_piece = 5 if play_white else -5

func _on_knight_button_pressed() -> void:
	if(piece_left[2] == 0): 
		selected_piece = 0
	else:
		selected_piece = 2 if play_white else -2

func _on_bishop_button_pressed() -> void:
	if(piece_left[3] == 0): 
		selected_piece = 0
	else:
		selected_piece = 3 if play_white else -3

func _on_rook_button_pressed() -> void:
	if(piece_left[4] == 0): 
		selected_piece = 0
	else:
		selected_piece = 4 if play_white else -4

func _on_pawn_button_pressed() -> void:
	if(piece_left[1] == 0): 
		selected_piece = 0
	else:
		selected_piece = 1 if play_white else -1


func _on_delete_mode_toggled(toggled_on: bool) -> void:
	if toggled_on:
		delete_mode.button_pressed = true
		is_delete = true
	else:
		delete_mode.button_pressed = false
		is_delete = false

func time_left_to_live():
	var total_sec = int(timer.time_left)
	var minute = total_sec / 60
	var second = total_sec % 60
	return [minute, second]
	
func _process(delta):
	timer_label.text = "%02d:%02d" % time_left_to_live()
	if(int(timer.time_left) == 0):
		random_place_piece()
		var peer_id = multiplayer.get_remote_sender_id()
		GlobalScript.chess_board_data = board
		GlobalScript.hidden_board_data = hidden_board
		iam_ready = true
		trigger_ready.rpc_id(peer_id, board)
	
func random_place_piece():
	var all_left = get_all_left()
	all_left.shuffle()
	var idx = 0
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			if(row <= 1 && board[row][col] == 0):
				board[row][col] = all_left[idx]
				idx += 1
		
func get_all_left():
	var all_left = []
	for idx in len(piece_left):
		for i in range(piece_left[idx]):
			var value = idx if play_white else -idx
			all_left.append(value)
	return all_left
	
func _init_parameter():
	play_white = GlobalScript.play_as == "white"
	delete_mode.button_pressed = false
	timer.wait_time = get_setting_phase_options(GlobalScript.setting_phase)
	timer.start()
	board = []
	hidden_board = []
	another_board = []
	piece_left = [0, 8, 2, 2, 2, 1, 1]
	another_ready = false
	iam_ready = false
	is_delete = false

func get_setting_phase_options(setting_phase):
	if(setting_phase == "1 min"):
		return 60
	elif(setting_phase == "3 min"):
		return 180
	elif(setting_phase == "5 min"):
		return 300


func _on_random_button_pressed() -> void:
	pass # Replace with function body.
