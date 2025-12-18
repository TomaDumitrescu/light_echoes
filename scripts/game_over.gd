extends Control

@onready var score_label: Label = $ScoreLabel
@onready var retry_button: Button = $RetryButton
@onready var menu_button: Button = $MenuButton

func _ready():
	AudioManager.stop_music()
	AudioManager.play_gameover_sfx()
	AudioManager.play_menu_music()
	score_label.text = "Score: " + str(PlayerStats.score) + "\nLevel: " + str(PlayerStats.current_level)
	PlayerStats.reset_score()
	retry_button.flat = true
	menu_button.flat = true
	pass

func _on_menu_button_button_down():
	AudioManager.play_sfx_on_bus(AudioManager.click_sfx,AudioManager.ui_bus_name)
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_retry_button_button_down():
	AudioManager.play_sfx_on_bus(AudioManager.click_sfx,AudioManager.ui_bus_name)
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _on_retry_button_mouse_entered() -> void:
	AudioManager.play_hover_sfx()
	
func _on_menu_button_mouse_entered() -> void:
	AudioManager.play_hover_sfx()
