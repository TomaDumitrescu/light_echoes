extends Node

@export var menu_music: AudioStream =preload("res://audio/menu_music.mp3")
@export var main_music: AudioStream =preload("res://audio/background_music.mp3")
@export var gameover_sfx: AudioStream =preload("res://audio/game-over_2.mp3")
@export var click_sfx: AudioStream = preload("res://audio/click_sfx.mp3")
@export var hover_button: AudioStream = preload("res://audio/hover-button.mp3")

var _current_music: AudioStream = null

var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_sfx_player = AudioStreamPlayer.new()
	add_child(_music_player)
	add_child(_sfx_player)

func play_music(stream: AudioStream) -> void:
	if stream == null:
		return
	if _current_music == stream and _music_player.playing:
		return

	_current_music = stream
	_music_player.stream = stream
	_music_player.play()

func play_menu_music() -> void:
	play_music(menu_music)

func play_main_music() -> void:
	play_music(main_music)

func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	_sfx_player.stream = stream
	_sfx_player.play()

func play_gameover_sfx() -> void:
	play_sfx(gameover_sfx)
	
func play_hover_sfx() -> void:
	play_sfx(hover_button)

func stop_music() -> void:
	_current_music = null
	_music_player.stop()
