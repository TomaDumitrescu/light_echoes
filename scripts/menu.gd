extends Control

func _ready() -> void:
	AudioManager.play_menu_music()

func _on_play_button_button_down():
	AudioManager.play_sfx_on_bus(AudioManager.click_sfx,AudioManager.ui_bus_name)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _on_play_button_mouse_entered() -> void:
	AudioManager.play_hover_sfx()


func _on_button_mouse_entered() -> void:
	AudioManager.play_hover_sfx()


func _on_button_button_down() -> void:
	AudioManager.play_sfx_on_bus(AudioManager.click_sfx,AudioManager.ui_bus_name)
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
