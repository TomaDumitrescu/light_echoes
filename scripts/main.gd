extends Node2D

@onready var tilemap: TileMap = $TileMap
@onready var player: Player = $Player

func _ready():
	tilemap.generate_map()
	position_player()
	#tilemap.generate_target()

func position_player():
	var player_position = tilemap.get_player_position()
	player.global_position = player_position
	
func _input(event):
	pass
	
func on_target_reached():
	get_tree().call_deferred("reload_current_scene")
