extends Node

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 9000
const CLIENT_IP = "127.0.0.1"
const GAME_PORT = 9001

### Create central server connection
func connect_to_lobby_server(peer: ENetMultiplayerPeer):
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
func request_to_create_room(ip: String, port: int):
	pass

@rpc("any_peer", "call_remote", "reliable")
func request_to_join_room(code: String):
	pass

@rpc("authority", "call_remote", "reliable")
func handle_room_created(code: String):
	print("Room created! Share this code: ", code)
	_start_game_host_server(GAME_PORT)

@rpc("authority", "call_remote", "reliable")
func handle_joined_room(is_success: bool, host_ip: String = "", host_port: int = 0):
	if(is_success):
		print("Joining game at ", host_ip, ":", host_port)
		_connect_to_game_host(host_ip, host_port)
	else:
		print("Failed to join room. Invalid code or room doesn't exist.")


### Function for main scene to call
func create_room():
	request_to_create_room.rpc_id(1, CLIENT_IP, GAME_PORT)

func join_room(room_code: String):
	request_to_join_room.rpc_id(1, room_code)


### Private function
func _on_lobby_connected(peer_id):
	print("Connected to lobby server")

func _on_lobby_disconnected(peer_id):
	print("Disconnected from lobby server")

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
		print("Connected to game host!")
	else:
		print("Failed to connect to game host.")
