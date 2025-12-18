extends Node

@export var menu_music: AudioStream = preload("res://audio/menu_music.mp3")
@export var main_music: AudioStream = preload("res://audio/background_music.mp3")
@export var gameover_sfx: AudioStream = preload("res://audio/game-over_2.mp3")
@export var click_sfx: AudioStream = preload("res://audio/click_sfx.mp3")
@export var hover_button: AudioStream = preload("res://audio/hover-button.mp3")
@export var hover_slider: AudioStream = preload("res://audio/slider.mp3")

@export var music_bus_name: String = "Music"
@export var sfx_bus_name: String = "SFX"
@export var ui_bus_name: String = "UI"

var _current_music: AudioStream = null

var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_sfx_player = AudioStreamPlayer.new()
	add_child(_music_player)
	add_child(_sfx_player)

	_music_player.bus = _safe_bus_name(music_bus_name)
	_sfx_player.bus = _safe_bus_name(sfx_bus_name)

func _safe_bus_name(bus_name: String) -> String:
	if AudioServer.get_bus_index(bus_name) != -1:
		return bus_name
	return "Master"

func play_music(stream: AudioStream) -> void:
	if stream == null:
		return
	if _current_music == stream and _music_player.playing:
		return

	_current_music = stream
	_music_player.bus = _safe_bus_name(music_bus_name)
	_music_player.stream = stream
	_music_player.play()

func play_menu_music() -> void:
	play_music(menu_music)

func play_main_music() -> void:
	play_music(main_music)

func play_sfx_on_bus(stream: AudioStream, bus_name: String) -> void:
	if stream == null:
		return

	_sfx_player.stop()
	_sfx_player.bus = _safe_bus_name(bus_name)
	_sfx_player.stream = stream
	_sfx_player.play()

func play_gameover_sfx() -> void:
	play_sfx_on_bus(gameover_sfx, sfx_bus_name)

func play_click_sfx() -> void:
	play_sfx_on_bus(click_sfx, ui_bus_name)

func play_hover_sfx() -> void:
	play_sfx_on_bus(hover_button, ui_bus_name)
	
func play_hover_slider_sfx() -> void:
	play_sfx_on_bus(hover_slider, ui_bus_name)
	

func stop_music() -> void:
	_current_music = null
	_music_player.stop()
