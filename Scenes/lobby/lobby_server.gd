extends Node

# Store room codes and their associated host info
# Format: 
# "room_code": {
#    "host_id": peer_id,
#    "host_ip": host_ip,
#    "host_port": port,
#    "game_info": {
#       "setting_phase": "1 min" | "3 min" | "5 min",
#       "play_phase": "10 min" | "15|10" | "30 min",
#       "play_as": "white" | "black" | "random",
#     }
# }
var rooms = {}

const SERVER_PORT = 9000

### Create Central Server connection
func start_lobby_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	print("Lobby server started on port " + str(SERVER_PORT))

### RPC - For client - server communication
@rpc("any_peer", "call_remote", "reliable")
func request_to_create_room(ip: String, port: int, game_info: Dictionary):
	var peer_id = multiplayer.get_remote_sender_id()
	
	var host_game_info = {
		"setting_phase": game_info.get("setting_phase"),
		"play_phase": game_info.get("play_phase"),
		"play_as": _get_play_as(game_info.get("play_as")),
	}
		
	var room_code = _generate_room_code()
	rooms[room_code] = {
		"host_id": peer_id,
		"host_ip": ip,
		"host_port": port,
		"game_info": host_game_info
	}

	print("Room created by peer ", peer_id, "with code: ", room_code)
	
	handle_room_created.rpc_id(peer_id, room_code, host_game_info)

@rpc("any_peer", "call_remote", "reliable")
func request_to_join_room(code: String):
	var peer_id = multiplayer.get_remote_sender_id()
	
	if rooms.has(code):
		var room_info = rooms[code]
		print("Player ", peer_id, " joining room ", code)
		
		var host_game_info = room_info.get("game_info")
		
		var game_info = {
			"setting_phase": host_game_info.get("setting_phase"),
			"play_phase": host_game_info.get("play_phase"),
			"play_as": "black" if host_game_info.get("play_as") == "white" else "white",
		}
		
		handle_joined_room.rpc_id(peer_id, true, room_info.get("host_ip"), room_info.get("host_port"), game_info)
		rooms.erase(code)
	else:
		print("Player ", peer_id, " failed to join room ", code)
		handle_joined_room.rpc_id(peer_id,false)

@rpc("authority", "call_remote", "reliable")
func handle_room_created(code: String, game_info: Dictionary):
	pass

@rpc("authority", "call_remote", "reliable")
func handle_joined_room(is_success: bool, host_ip: String = "", host_port: int = 0, game_info: Dictionary = {}):
	pass
	
### Private function
func _generate_room_code() -> String:
	const CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var code = ""
	
	while code == "" or rooms.has(code):
		for i in 10:
			code += CHARS[randi() % CHARS.length()]
		
	return code

func _get_play_as(play_as: String) -> String:
	const colors = ["black", "white"]
	if(play_as == "random"):
		return colors[randi() % colors.size()]
	return play_as
