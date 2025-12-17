extends Control

func _ready() -> void:
	AudioManager.play_menu_music()

func _on_play_button_button_down():
	AudioManager.play_sfx(AudioManager.click_sfx)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _on_play_button_mouse_entered() -> void:
	AudioManager.play_hover_sfx()
