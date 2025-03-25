extends Sprite2D

const BOARD_SIZE = 8
const CELL_WIDTH = 60

const TEXTURE_HOLDER_SETUP = preload("res://Scenes/texture_holder_setup.tscn")

const BLACK_BISHOP = preload("res://Assets/Piece/black_bishop.png")
const BLACK_KING = preload("res://Assets/Piece/black_king.png")
const BLACK_KNIGHT = preload("res://Assets/Piece/black_knight.png")
const BLACK_PAWN = preload("res://Assets/Piece/black_pawn.png")
const BLACK_QUEEN = preload("res://Assets/Piece/black_queen.png")
const BLACK_ROOK = preload("res://Assets/Piece/black_rook.png")
const BLACK_HIDDEN = preload("res://Assets/Piece/black_hidden.png")
const WHITE_BISHOP = preload("res://Assets/Piece/white_bishop.png")
const WHITE_KING = preload("res://Assets/Piece/white_king.png")
const WHITE_KNIGHT = preload("res://Assets/Piece/white_knight.png")
const WHITE_PAWN = preload("res://Assets/Piece/white_pawn.png")
const WHITE_QUEEN = preload("res://Assets/Piece/white_queen.png")
const WHITE_ROOK = preload("res://Assets/Piece/white_rook.png")
const WHITE_HIDDEN = preload("res://Assets/Piece/white_hidden.png")

@onready var pieces: Node2D = $Pieces
@onready var dots: Node2D = $Dots

#Variables
var board : Array = []
var hidden_board: Array = []
var white : bool
var state : bool
var moves = []
var selected_piece : Vector2

func _ready():
	board.append([4, 2, 3, 5, 6, 3, 2, 4])
	board.append([1, 1, 1, 1, 1, 1, 1, 1])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([0, 0, 0, 0, 0, 0, 0, 0])
	board.append([-4, -2, -3, -5, -6, -3, -2, -4])
	board.append([-1 ,-1 ,-1 ,-1 ,-1 ,-1 ,-1 ,-1])
	hidden_board.append([2, 2, 2, 2, 2, 2, 2, 2]) # 0,0 == bottom left
	hidden_board.append([2, 2, 2, 2, 2, 2, 2, 2])
	hidden_board.append([0, 0, 0, 0, 0, 0, 0, 0])
	hidden_board.append([0, 0, 0, 0, 0, 0, 0, 0])
	hidden_board.append([0, 0, 0, 0, 0, 0, 0, 0])
	hidden_board.append([0, 0, 0, 0, 0, 0, 0, 0])
	hidden_board.append([2, 2, 2, 2, 2, 2, 2, 2])
	hidden_board.append([2, 2, 2, 2, 2, 2, 2, 2])
	
	display_board()
	
func display_board():
	for i in BOARD_SIZE:
		for j in BOARD_SIZE:
			var holder = TEXTURE_HOLDER_SETUP.instantiate()
			pieces.add_child(holder)
			holder.global_position = Vector2(j * CELL_WIDTH + (CELL_WIDTH / 2) + 112, i * CELL_WIDTH + (CELL_WIDTH / 2) + 80)
			
			match board[i][j]:
				-6: holder.texture = BLACK_KING
				-5: holder.texture = BLACK_QUEEN
				-4: holder.texture = BLACK_ROOK
				-3: holder.texture = BLACK_BISHOP
				-2: holder.texture = BLACK_KNIGHT
				-1: holder.texture = BLACK_PAWN
				0 : holder.texture = null
				6: holder.texture = WHITE_KING
				5: holder.texture = WHITE_QUEEN
				4: holder.texture = WHITE_ROOK
				3: holder.texture = WHITE_BISHOP
				2: holder.texture = WHITE_KNIGHT
				1: holder.texture = WHITE_PAWN
			holder.scale = Vector2(0.3, 0.3)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_button_2_pressed() -> void:
	GlobalScript.chess_board_data = board
	GlobalScript.hidden_board_data = hidden_board
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
