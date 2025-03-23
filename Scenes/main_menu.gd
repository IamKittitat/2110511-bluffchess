extends Node

# CONNECTION
var lobby_server = preload("res://Scenes/lobby/lobby_server.gd").new()
var lobby_client = preload("res://Scenes/lobby/lobby_client.gd").new()

# SCENE
var credit_scene = load("res://Scenes/credit.tscn")
var main = load("res://Scenes/main.tscn")

func _ready():
	var args = OS.get_cmdline_args()
	if "--server" in args:
		print("Running as Lobby Server")
		add_child(lobby_server)
		lobby_server.start_lobby_server()
	else:
		add_child(lobby_client)
		lobby_client.connect_to_lobby_server()

func _on_new_room_pressed() -> void:
	lobby_client.create_room()
	#get_tree().change_scene_to_packed(main)

func _on_join_room_button_pressed() -> void:
	# This room code must be in JOIN scene
	lobby_client.join_room("YNtxLcnWKu")

func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_packed(credit_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
