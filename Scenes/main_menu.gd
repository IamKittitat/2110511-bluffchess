extends Node

# CONNECTION
var lobby_server = preload("res://Scenes/lobby/lobby_server.gd").new()
var lobby_client = preload("res://Scenes/lobby/lobby_client.gd").new()

# SCENE
var create_room_scene = load("res://Scenes/lobby/create_room/create_room.tscn")
var join_room_scene = load("res://Scenes/lobby/join_room/join_room.tscn")
var credit_scene = load("res://Scenes/credit.tscn")
var main = load("res://Scenes/main.tscn")

func _ready():
	var args = OS.get_cmdline_args()
	if "--server" in args:
		print("Running as Lobby Server")
		lobby_server.name = "Lobby"
		get_tree().root.add_child.call_deferred(lobby_server)
	else:
		if not get_tree().root.has_node("/root/Lobby"):
			lobby_client.name = "Lobby"
			get_tree().root.add_child.call_deferred(lobby_client)
		else:
			lobby_client = get_tree().root.get_node('/root/Lobby')
			lobby_client.connect_to_lobby_server()

func _on_new_room_pressed() -> void:
	get_tree().change_scene_to_packed(create_room_scene)

func _on_join_room_button_pressed() -> void:
	get_tree().change_scene_to_packed(join_room_scene)

func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_packed(credit_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
