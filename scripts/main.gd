extends Node2D

@onready var map: Map = $TileMap
@onready var player: Player = $FireFly
@onready var minimap: MiniMap = $MiniMap

const SCENES = {
	"BAT": preload("res://scenes/Enemies/Bat.tscn"),
	"STACTALITE": preload("res://scenes/Enemies/Stalactite.tscn"),
	"SPIDER": preload("res://scenes/Enemies/Spider.tscn"),
	"SLIME": preload("res://scenes/Enemies/Slime.tscn"),
}

@export var dspike = 0.85

const OBSTACLE_SCENES = {
	"GROWINGPLANT": preload("res://scenes/Obstacles/GrowingPlant.tscn"),
	"LAVA": preload("res://scenes/Obstacles/Lava.tscn"),
	"MIRROR": preload("res://scenes/Obstacles/Mirror.tscn"),
	"SPIKETRAP": preload("res://scenes/Obstacles/SpikeTrap.tscn")
}
func _ready():
	var map_generator = MapGenerator.new()
	map_generator.generate_map()
	map.create(map_generator.map)
	map_generator.add_markers()
	minimap.init_explored(map_generator.width, map_generator.height)
	position_player(map_generator)
	add_markers_on_map(map_generator)
	
	spawn_random_at_markers("BAT", "MIRROR", map_generator.air_markers)
	spawn_random_at_markers("STACTALITE", "SPIKETRAP", map_generator.ceiling_markers)
	spawn_random_at_markers("SPIDER", "LAVA", map_generator.side_markers)
	spawn_random_at_markers("SLIME", "GROWINGPLANT", map_generator.ground_markers)

func add_markers_on_map(map_generator):
	map.add_air_elements(map_generator.air_markers, player.global_position / Map.TILE_SIZE)
	map.add_ground_elements(map_generator.ground_markers, player.global_position / Map.TILE_SIZE)
	map.add_ceiling_elements(map_generator.ceiling_markers, player.global_position / Map.TILE_SIZE)
	map.add_side_elements(map_generator.side_markers, player.global_position / Map.TILE_SIZE)

func position_player(map_generator: MapGenerator):
	var player_cell = null
	var max_iterations = 100

	while max_iterations > 0:
		max_iterations -= 1
		player_cell = map_generator.get_empty_cell()
		if player_cell.distance_to(map_generator.exit_cell) >= (map.map_width  - 2) / 2:
			break

	player.global_position = player_cell * Map.TILE_SIZE

func on_target_reached():
	get_tree().call_deferred("reload_current_scene")
	
func spawn_random_at_markers(sceneName: String, oSceneName: String, markers: Array):
	var enemyScene: PackedScene = SCENES[sceneName]
	var oScene: PackedScene = OBSTACLE_SCENES[oSceneName]
	for m in markers:
		if randf() < 0.6:
			var enemy = enemyScene.instantiate()
			add_child(enemy)
			enemy.global_position = m * Map.TILE_SIZE
		else:
			var obstacle: Node = oScene.instantiate()
			add_child(obstacle)
			obstacle.global_position = m * Map.TILE_SIZE
			if oSceneName == "SPIKETRAP":
				obstacle.global_position += Vector2(dspike, dspike) * Map.TILE_SIZE
