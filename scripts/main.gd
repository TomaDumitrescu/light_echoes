extends Node2D

@onready var map: Map = $TileMap
@onready var player: Player = $FireFly
@onready var minimap: MiniMap = $MiniMap


const SCENES = {
	"BAT": preload("res://scenes/Enemies/Bat.tscn"),
	"MOTH": preload("res://scenes/Enemies/Moth.tscn"),
	"STACTALITE": preload("res://scenes/Enemies/Stalactite.tscn"),
	"SPIDER": preload("res://scenes/Enemies/Spider.tscn"),
	"SLIME": preload("res://scenes/Enemies/Slime.tscn"),
}

@export var dplant = 1.25
@export var dspike = 0.85

const OBSTACLE_SCENES = {
	"GROWINGPLANT": preload("res://scenes/Obstacles/GrowingPlant.tscn"),
	"LAVA": preload("res://scenes/Obstacles/Lava.tscn"),
	"MIRROR": preload("res://scenes/Obstacles/Mirror.tscn"),
	"SPIKETRAP": preload("res://scenes/Obstacles/SpikeTrap.tscn")
}
func _ready():
	AudioManager.play_main_music()

	var map_generator = MapGenerator.new()
	map_generator.generate_map()
	map.create(map_generator.map)
	map_generator.add_markers()
	minimap.init_explored(map_generator.width, map_generator.height)
	position_player(map_generator)
	add_markers_on_map(map_generator)

	spawn_random_at_markers(["BAT", "MOTH"], "MIRROR", map_generator.air_markers, map_generator)
	spawn_random_at_markers(["STACTALITE"], "SPIKETRAP", map_generator.ceiling_markers, map_generator)
	spawn_random_at_markers(["SPIDER"], "", map_generator.side_markers, map_generator)
	spawn_random_at_markers([], "LAVA", map_generator.lava_markers, map_generator)
	spawn_random_at_markers(["SLIME"], "GROWINGPLANT", map_generator.ground_markers, map_generator)

func add_markers_on_map(map_generator):
	map.add_air_elements(map_generator.air_markers, player.global_position / Map.TILE_SIZE)
	map.add_ground_elements(map_generator.ground_markers, player.global_position / Map.TILE_SIZE)
	map.add_ceiling_elements(map_generator.ceiling_markers, player.global_position / Map.TILE_SIZE)
	map.add_side_elements(map_generator.side_markers, player.global_position / Map.TILE_SIZE)
	map.add_corner_elements(map_generator.lava_markers)

var dx = [-1, 0, 1, 0]
var dy = [0, 1, 0, -1]
func is_dist_ok(player_cell: Vector2i, markers: Array[Vector2i]):
	for m in markers:
		if m.distance_to(player_cell) <= 3:
			return false
	return true

func h(start: Vector2i, end: Vector2i) -> float:
	return start.distance_to(end)

func calculate_path(map_generator: MapGenerator, startn: Vector2i, endn: Vector2i) -> bool:
	if !map_generator.is_walkable(startn[0], startn[1]):
		return false
	var open = PriorityQueue.new()
	var g_score = {}
	var f_score = {}

	for x in range(0, map_generator.width):
		for y in range(0, map_generator.height):
			g_score[Vector2i(x, y)] = pow(map_generator.width * map_generator.height, 4)
			f_score[Vector2i(x, y)] = pow(map_generator.width * map_generator.height, 4)

	g_score[startn] = 0
	f_score[startn] = h(startn, endn)

	open.push(startn, f_score[startn])

	var closed = {}
	while !open.is_empty():
		var current = open.peek_min()
		var node = current["value"]
		if node == endn:
			return true

		open.pop_min()
		var x = node[0]
		var y = node[1]
		var distance = current["priority"]
		
		if closed.has(node):
			continue
		closed[node] = true

		for v in range(0, 4):
			var xv = x + dx[v]
			var yv = y + dy[v]

			if xv < 0 or xv >= map_generator.width or yv < 0 or yv >= map_generator.height or !(map_generator.is_walkable(xv, yv) or map_generator.map[xv][yv] == MapGenerator.EXIT):
				continue

			var tentative_g = g_score[node] + 1
			var neighbor = Vector2i(xv, yv)
			
			if closed.has(neighbor):
				continue

			if tentative_g < g_score[neighbor]:
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + h(neighbor, endn)

			if !open.container.has(neighbor):
				open.push(neighbor, f_score[neighbor])

	return false

func position_player(map_generator: MapGenerator):
	var player_cell = null
	var max_iterations = 1000

	while max_iterations > 0:
		max_iterations -= 1
		player_cell = map_generator.get_empty_cell()

		if !is_dist_ok(player_cell, map_generator.lava_markers) or !is_dist_ok(player_cell, map_generator.ground_markers):
			continue

		if !is_dist_ok(player_cell, map_generator.ceiling_markers) or !is_dist_ok(player_cell, map_generator.air_markers) or !is_dist_ok(player_cell, map_generator.side_markers):
			continue

		if !calculate_path(map_generator, player_cell, map_generator.exit_cell):
			print("WHAT")
			continue

		if player_cell.distance_to(map_generator.exit_cell) >= (map.map_width  - 2) / 2 or max_iterations < 100:
			break

	player.global_position = player_cell * Map.TILE_SIZE

func on_target_reached():
	get_tree().call_deferred("reload_current_scene")
	
func spawn_random_at_markers(sceneNames: Array, oSceneName: String, markers: Array, map_generator: MapGenerator):
	var oScene: PackedScene = null
	if oSceneName.length() >= 1:
		oScene = OBSTACLE_SCENES[oSceneName]
		
	for m in markers:
		var random = randf()
		var enemyScene: PackedScene = null
		if sceneNames.size() >= 1:
			var chosen_name = sceneNames[randi() % sceneNames.size()]
			if SCENES.has(chosen_name):
				enemyScene = SCENES[chosen_name]
				
		if random < 0.6 and enemyScene != null:
			var enemy = enemyScene.instantiate()
			add_child(enemy)
			enemy.global_position = m * Map.TILE_SIZE

		elif oScene != null and random >= 0.4:
			var obstacle: Node = oScene.instantiate()
			add_child(obstacle)
			obstacle.global_position = m * Map.TILE_SIZE
			if oSceneName == "GROWINGPLANT":
				obstacle.global_position = Vector2(m[0], m[1] + dplant) * Map.TILE_SIZE
			elif oSceneName == "SPIKETRAP":
				var rN: Vector2i = Vector2i(m[0] + 1, m[1])
				var lN: Vector2i = Vector2i(m[0] - 1, m[1])
				if map_generator.is_in_map(rN[1], rN[0], map_generator.width, map_generator.height) and map_generator.map[rN[0]][rN[1]] == map_generator.WALL:
					obstacle.global_position += Vector2(-dspike, dspike) * Map.TILE_SIZE
				elif map_generator.is_in_map(lN[1], lN[0], map_generator.width, map_generator.height) and map_generator.map[lN[0]][lN[1]] == map_generator.WALL:
					obstacle.global_position += Vector2(dspike, dspike) * Map.TILE_SIZE
				else:
					obstacle.global_position += Vector2(0, dspike) * Map.TILE_SIZE
