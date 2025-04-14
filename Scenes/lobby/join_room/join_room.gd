extends Control

# Handle code enter
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_join_button_pressed() -> void:
	var lobby_client = get_tree().root.get_node('/root/Lobby')
	lobby_client.join_room(GlobalScript.room_code)


func _on_room_code_text_changed(new_text: String) -> void:
	GlobalScript.room_code = new_text
	_update_join_room_button_state()

func _update_join_room_button_state():
	var join_room_button = $"Panel/JoinRoomButton"
	join_room_button.disabled = not _is_input_valid()

func _is_input_valid():
	return GlobalScript.room_code.length() == 10
