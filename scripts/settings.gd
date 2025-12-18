extends Node2D

@onready var home: Button = $Home

func _ready() -> void:
	home.flat = true
	
func _on_home_button_down() -> void:
	AudioManager.play_sfx_on_bus(AudioManager.click_sfx,AudioManager.ui_bus_name)
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_home_mouse_entered() -> void:
	AudioManager.play_hover_sfx()
	


func _on_music_mouse_entered() -> void:
	AudioManager.play_hover_slider_sfx()


func _on_sfx_mouse_entered() -> void:
	AudioManager.play_hover_slider_sfx()


func _on_ui_mouse_entered() -> void:
	AudioManager.play_hover_slider_sfx()
