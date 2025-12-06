extends Node2D

@onready var map: Map = $TileMap
@onready var player: Player = $Player
@onready var minimap: MiniMap = $MiniMap

func _ready():
	var map_generator = MapGenerator.new()
	map_generator.generate_map()
	map.create(map_generator.map)
	minimap.init_explored(map_generator.width, map_generator.height)
	position_player(map_generator)

func position_player(map_generator: MapGenerator):
	var player_cell = map_generator.get_empty_cell()
	player.global_position = player_cell * Map.TILE_SIZE
	
func on_target_reached():
	get_tree().call_deferred("reload_current_scene")
