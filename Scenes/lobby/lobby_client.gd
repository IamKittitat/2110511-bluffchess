extends Node

var game_join = preload("res://Scenes/game_peer/game_join.gd").new()

# Scene
var waiting_room_scene = load("res://Scenes/lobby/waiting_room/waiting_room.tscn")

# Connection Information
const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 9000
const CLIENT_IP = "127.0.0.1"
const GAME_PORT = 9001

func _ready():
	connect_to_lobby_server()

### Create central server connection
func connect_to_lobby_server():
	var peer = ENetMultiplayerPeer.new()
	add_child(game_join)
	var err = peer.create_client(SERVER_IP, SERVER_PORT)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_on_lobby_connected)
		multiplayer.peer_disconnected.connect(_on_lobby_disconnected)
		print("Connecting to lobby server...")
	else:
		print("Failed to connect to lobby server.")

### RPC - For communicate with central server
@rpc("any_peer", "call_remote", "reliable")
func request_to_create_room(ip: String, port: int, game_info: Dictionary):
	pass

@rpc("any_peer", "call_remote", "reliable")
func request_to_join_room(code: String):
	pass

@rpc("authority", "call_remote", "reliable")
func handle_room_created(code: String, game_info: Dictionary):
	print("Room created! Share this code: ", code)
	game_join.set_initial_game_info(game_info)
	_start_game_host_server(GAME_PORT)
	
	GlobalScript.room_code = code
	get_tree().change_scene_to_packed(waiting_room_scene)

@rpc("authority", "call_remote", "reliable")
func handle_joined_room(is_success: bool, host_ip: String = "", host_port: int = 0, game_info: Dictionary = {}):
	if(is_success):
		print("Joining game at ", host_ip, ":", host_port)
		game_join.set_initial_game_info(game_info)
		_connect_to_game_host(host_ip, host_port)
	else:
		print("Failed to join room. Invalid code or room doesn't exist.")

@rpc("any_peer", "call_remote", "reliable")
func remove_room_code(code: String):
	pass

### Function for main scene to call
func create_room(setting_phase: String, play_phase: String, play_as: String):
	var game_info = {
		"setting_phase": setting_phase,
		"play_phase": play_phase,
		"play_as": play_as
	}
	request_to_create_room.rpc_id(1, CLIENT_IP, GAME_PORT, game_info)

func join_room(room_code: String):
	request_to_join_room.rpc_id(1, room_code)


### Private function
func _on_lobby_connected(peer_id):
	print("Connected to lobby server")
	# In case go back to main menu after create the room	
	_clear_host_game()


func _on_lobby_disconnected(peer_id):
	print("Disconnected from lobby server")
	
func _clear_host_game():
	if(GlobalScript.room_code != ""):
		remove_room_code.rpc_id(1, GlobalScript.room_code)
		GlobalScript.room_code = ""

func _start_game_host_server(port: int):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		print("Game host server started on port ", port)
	else:
		print("Failed to start game host server.")

func _connect_to_game_host(ip: String, port: int):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, port)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		# wait for connection before calling rpc
		await get_tree().create_timer(1).timeout
		game_join.on_game_peer_ready.rpc()
		print("Connected to game host!")
	else:
		print("Failed to connect to game host.")
