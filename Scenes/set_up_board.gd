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
@onready var dots: Node2D = $Dots

var board : Array = []
var hidden_board: Array = []
var is_my_turn: bool
var play_white : bool
var state : String = "CHOOSE" # CHOOSE, PLACE 

func _ready():
	play_white = GlobalScript.play_as == "white"
	
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	hidden_board.append([2, 2, 2, 2, 2, 2, 2, 2])
	hidden_board.append([2, 2, 2, 2, 2, 2, 2, 2])
	hidden_board.append([0, 0, 0, 0, 0, 0, 0, 0])
	hidden_board.append([0, 0, 0, 0, 0, 0, 0, 0])
	hidden_board.append([0, 0, 0, 0, 0, 0, 0, 0])
	hidden_board.append([0, 0, 0, 0, 0, 0, 0, 0])
	hidden_board.append([2, 2, 2, 2, 2, 2, 2, 2])
	hidden_board.append([2, 2, 2, 2, 2, 2, 2, 2])
	
	display_board()
	
func display_board():
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

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_button_2_pressed() -> void:
	GlobalScript.chess_board_data = board
	GlobalScript.hidden_board_data = hidden_board
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_king_button_pressed() -> void:
	pass # Replace with function body.


func _on_queen_button_pressed() -> void:
	pass # Replace with function body.


func _on_knight_button_pressed() -> void:
	pass # Replace with function body.


func _on_bishop_button_pressed() -> void:
	pass # Replace with function body.


func _on_rook_button_pressed() -> void:
	pass # Replace with function body.


func _on_pawn_button_pressed() -> void:
	pass # Replace with function body.
