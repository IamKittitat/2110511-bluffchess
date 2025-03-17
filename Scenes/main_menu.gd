extends Control

var credit_scene = load("res://Scenes/credit.tscn")
var main = load("res://Scenes/main.tscn")

func _on_new_room_pressed() -> void:
	get_tree().change_scene_to_packed(main)


func _on_join_room_button_pressed() -> void:
	pass # Replace with function body.


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_packed(credit_scene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
