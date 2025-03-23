extends Node

var main = load("res://Scenes/main.tscn")

### RPC - for communication between peer
@rpc("any_peer", "call_local", "reliable")
func on_game_peer_ready():
	get_tree().change_scene_to_packed(main)
