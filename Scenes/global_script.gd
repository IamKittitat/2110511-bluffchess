extends Node

var room_code: String = ""

var chess_board_data = []
var hidden_board_data = []

var setting_phase
var play_phase
var play_as


const setting_phase_options = [ "1 min" , "3 min" , "5 min"]
const play_phase_options =["10 min" , "15|10" , "30 min"]
const play_as_options = ["white" , "random", "black"]
