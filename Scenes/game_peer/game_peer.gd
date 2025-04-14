extends Node

var set_up = load("res://Scenes/set_up_page.tscn")
var main = load("res://Scenes/main.tscn")
var board = load("res://Scenes/board.tscn").instantiate()


### RPC - for communication between peer
@rpc("any_peer", "call_local", "reliable")
func on_game_peer_ready():
	print("Setting phase: ", GlobalScript.setting_phase)
	print("Play phase: ", GlobalScript.play_phase)
	print("Play as: ", GlobalScript.play_as)

	get_tree().change_scene_to_packed(set_up)

### Private function
func _on_game_peer_connected(peer_id):
	print("Connected to game peer")

func _on_game_peer_disconnected(peer_id):
	print("Disconnected from game peer")

### Setter
func set_initial_game_info(game_info: Dictionary):
	GlobalScript.setting_phase = game_info.get("setting_phase")
	GlobalScript.play_phase = game_info.get("play_phase")
	GlobalScript.play_as = game_info.get("play_as")

### Start and Connect
func start_game_host_server(port: int):
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		if not multiplayer.peer_connected.is_connected(_on_game_peer_connected):
			multiplayer.peer_connected.connect(_on_game_peer_connected)
		if not multiplayer.peer_disconnected.is_connected(_on_game_peer_disconnected):
			multiplayer.peer_disconnected.connect(_on_game_peer_disconnected)
			
		print("Game host server started on port ", port)
	else:
		print("Failed to start game host server.")

func connect_to_game_host(ip: String, port: int):	
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, port)
	if err == OK:
		multiplayer.multiplayer_peer = peer
		if not multiplayer.peer_connected.is_connected(_on_game_peer_connected):
			multiplayer.peer_connected.connect(_on_game_peer_connected)
		if not multiplayer.peer_disconnected.is_connected(_on_game_peer_disconnected):
			multiplayer.peer_disconnected.connect(_on_game_peer_disconnected)

		# wait for connection before calling rpc
		await get_tree().create_timer(1).timeout
		on_game_peer_ready.rpc()
		print("Connected to game host!")
	else:
		print("Failed to connect to game host.")
