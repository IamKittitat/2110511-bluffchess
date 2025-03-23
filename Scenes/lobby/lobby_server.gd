extends Node

# Store room codes and their associated host info
# Format: 
# "room_code": {
#    "host_id": peer_id,
#    "host_ip": host_ip,
#    "host_port": port,
# }
var rooms = {}

const SERVER_PORT = 9000

### Create Central Server connection
func start_lobby_server(peer: ENetMultiplayerPeer):
	peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	print("Lobby server started on port " + str(SERVER_PORT))

### RPC - For client - server communication
@rpc("any_peer", "call_remote", "reliable")
func request_to_create_room(ip: String, port: int):
	var peer_id = multiplayer.get_remote_sender_id()
	
	var room_code = _generate_room_code()
	rooms[room_code] = {
		"host_id": peer_id,
		"host_ip": ip,
		"host_port": port,
	}

	print("Room created by peer ", peer_id, "with code: ", room_code)
	
	handle_room_created.rpc_id(peer_id, room_code)

@rpc("any_peer", "call_remote", "reliable")
func request_to_join_room(code: String):
	var peer_id = multiplayer.get_remote_sender_id()
	
	if rooms.has(code):
		var room_info = rooms[code]
		print("Player ", peer_id, " joining room ", code)
		handle_joined_room.rpc_id(peer_id, true, room_info["host_ip"], room_info["host_port"])
		rooms.erase(code)
	else:
		print("Player ", peer_id, " failed to join room ", code)
		handle_joined_room.rpc_id(peer_id,false)

@rpc("authority", "call_remote", "reliable")
func handle_room_created(code: String):
	pass

@rpc("authority", "call_remote", "reliable")
func handle_joined_room(is_success: bool, host_ip: String = "", host_port: int = 0):
	pass
	
### Private function
func _generate_room_code() -> String:
	const CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var code = ""
	
	while code == "" or rooms.has(code):
		for i in 10:
			code += CHARS[randi() % CHARS.length()]
		
	return code
