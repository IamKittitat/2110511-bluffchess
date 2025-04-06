extends Control

var setting_phase_index = -1
var play_phase_index = -1
var play_as_index = -1

func _update_create_room_button_state():
	var create_room_button = $"CreateButton"
	create_room_button.disabled = not _is_input_valid()

func _is_input_valid():
	return setting_phase_index != -1 and play_phase_index != -1 and play_as_index != -1
	

func _on_create_button_pressed() -> void:
	if _is_input_valid():
		var lobby_client = get_tree().root.get_node('/root/Lobby')
		var setting_phase = GlobalScript.setting_phase_options[setting_phase_index]
		var play_phase = GlobalScript.play_phase_options[play_phase_index]
		var play_as = GlobalScript.play_as_options[play_as_index]
		lobby_client.create_room(setting_phase, play_phase, play_as)
	
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_setting_phase_selected(option_index: int):
	setting_phase_index = option_index
	_update_create_room_button_state()
	

func _on_play_phase_selected(option_index: int):
	play_phase_index = option_index
	_update_create_room_button_state()


func _on_play_as_selected(option_index: int):
	play_as_index = option_index
	_update_create_room_button_state()
