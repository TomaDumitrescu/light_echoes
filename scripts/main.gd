extends Node2D

@onready var tilemap: WorldMap = $TileMap
@onready var player: Player = $Player
@onready var minimap: MiniMap = $MiniMap

func _ready():
	tilemap.generate_map()
	minimap.init_explored(tilemap.map_width, tilemap.map_height)
	position_player()
	#tilemap.generate_target()

func position_player():
	var player_position = tilemap.get_player_position()
	player.global_position = player_position
	
func _input(event):
	pass
	
func on_target_reached():
	get_tree().call_deferred("reload_current_scene")
