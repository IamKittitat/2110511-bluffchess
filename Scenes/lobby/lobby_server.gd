extends Node

# Store room codes and their associated host info
# Format: 
# "room_code": {
#    "host_id": peer_id,
#    "host_ip": host_ip,
#    "host_port": port,
#    "is_other_connected": false
# }
var rooms = {}

const SERVER_PORT = 9000

func start_lobby_server(peer: ENetMultiplayerPeer):
	peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	print("Lobby server started on port " + str(SERVER_PORT))

# Generate a random 4-letter room code
func _generate_room_code() -> String:
	const CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var code = ""
	
	while code == "" or rooms.has(code):
		for i in 10:
			code += CHARS[randi() % CHARS.length()]
		
	return code

@rpc("authority", "call_remote", "reliable")
func room_created(code: String):
	pass

@rpc("authority", "call_remote", "reliable")
func join_room_success(host_ip: String, host_port: int):
	pass

@rpc("authority", "call_remote", "reliable")
func join_room_failed():
	pass

@rpc("any_peer", "call_remote", "reliable")
func request_create_room(ip: String, port: int):
	var peer_id = multiplayer.get_remote_sender_id()
	
	var room_code = _generate_room_code()
	rooms[room_code] = {
		"host_id": peer_id,
		"host_ip": ip,
		"host_port": port,
		"is_other_connected": false
	}

	print("Room created by peer ", peer_id, "with code: ", room_code)
	
	# Send the code back to the host that requested it
	room_created.rpc_id(peer_id, room_code)

@rpc("any_peer", "call_remote", "reliable")
func request_join_room(code: String):
	var peer_id = multiplayer.get_remote_sender_id()
	
	if rooms.has(code) and not rooms[code]["is_other_connected"]:
		rooms[code]["is_other_connected"] = true
		var room_info = rooms[code]
		print("Player ", peer_id, " joining room ", code)
		join_room_success.rpc_id(peer_id, room_info["host_ip"], room_info["host_port"])
	else:
		print("Player ", peer_id, " failed to join room ", code)
		join_room_failed.rpc_id(peer_id)
