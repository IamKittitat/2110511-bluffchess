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
	
### Setter
func set_initial_game_info(game_info: Dictionary):
	GlobalScript.setting_phase = game_info.get("setting_phase")
	GlobalScript.play_phase = game_info.get("play_phase")
	GlobalScript.play_as = game_info.get("play_as")
