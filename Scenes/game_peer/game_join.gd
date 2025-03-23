extends Node

var main = load("res://Scenes/main.tscn")

var setting_phase
var play_phase
var play_as

### RPC - for communication between peer
@rpc("any_peer", "call_local", "reliable")
func on_game_peer_ready():
	print("Setting phase: ", setting_phase)
	print("Play phase: ", play_phase)
	print("Play as: ", play_as)
	get_tree().change_scene_to_packed(main)

### Setter
func set_initial_game_info(game_info: Dictionary):
	setting_phase = game_info.get("setting_phase")
	play_phase = game_info.get("play_phase")
	play_as = game_info.get("play_as")
