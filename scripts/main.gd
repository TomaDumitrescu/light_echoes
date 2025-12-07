extends Node2D

@onready var map: Map = $TileMap
@onready var player: Player = $Player
@onready var minimap: MiniMap = $MiniMap

func _ready():
	var map_generator = MapGenerator.new()
	map_generator.generate_map()
	map.create(map_generator.map)
	map_generator.add_markers()
	minimap.init_explored(map_generator.width, map_generator.height)
	position_player(map_generator)
	add_markers_on_map(map_generator)

func add_markers_on_map(map_generator):
	map.add_air_elements(map_generator.air_markers, player.global_position / Map.TILE_SIZE)
	map.add_ground_elements(map_generator.ground_markers, player.global_position / Map.TILE_SIZE)
	map.add_ceiling_elements(map_generator.ceiling_markers, player.global_position / Map.TILE_SIZE)
	map.add_side_elements(map_generator.side_markers, player.global_position / Map.TILE_SIZE)

func position_player(map_generator: MapGenerator):
	var player_cell = null
	var max_iterations = 50

	while max_iterations > 0:
		max_iterations -= 1
		player_cell = map_generator.get_empty_cell()
		if player_cell.distance_to(map_generator.exit_cell) >= (map.map_width  - 2) / 2:
			break

	player.global_position = player_cell * Map.TILE_SIZE

func on_target_reached():
	get_tree().call_deferred("reload_current_scene")
