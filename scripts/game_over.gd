extends Control

func _on_menu_button_button_down():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_retry_button_button_down():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
