extends Control


func _ready():
	var text_label = $"Panel/Room Code"
	text_label.text = "[color=#383838]" + GlobalScript.room_code +  "[/color]!"

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
