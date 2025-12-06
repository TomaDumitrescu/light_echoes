extends TileMap
class_name WorldMap

const block_threshold = 0.5
const tile_size = 64
const map_width = 128
const map_height = 64
const noise_scale = 0.1

const BACKGROUND_LAYER = 0
const FOREGROUND_LAYER = 1

const ROCK_ID = 2
const BACKGROUND_ID = 3

func generate_map():
	clear()
	
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = noise_scale
	
	for x in range(map_width):
		for y in range(map_height):
			var noise_value = noise.get_noise_2d(x,y)
			noise_value = (noise_value + 1) / 2
			
			var tile_position = Vector2i(x, y)
			if noise_value < block_threshold:
				set_cell(FOREGROUND_LAYER, tile_position, ROCK_ID, Vector2i(0, 0))
			
			set_cell(BACKGROUND_LAYER, tile_position, BACKGROUND_ID, Vector2i(0, 0))
			
	for x in range(-1, map_width):	
		set_cell(FOREGROUND_LAYER, Vector2i(x, -1), ROCK_ID, Vector2i(0, 0))
		set_cell(FOREGROUND_LAYER, Vector2i(x, map_height), ROCK_ID, Vector2i(0, 0))
		
	for y in range(-1, map_height):	
		set_cell(FOREGROUND_LAYER, Vector2i(-1, y), ROCK_ID, Vector2i(0, 0))
		set_cell(FOREGROUND_LAYER, Vector2i(map_width, y), ROCK_ID, Vector2i(0, 0))

func get_player_position():
	var col = randi_range(0, map_width)
	var row = randi_range(0, map_height)
	var tile = Vector2i(col, row)
	
	while(not is_walkable(tile)):
		col = randi_range(0, map_width)
		row = randi_range(0, map_height)
		tile = Vector2i(col, row)
	var world_position = tile * tile_size
	return world_position
	
func generate_target(player_position: Vector2):
	var target_position = Vector2()
	var path = calculate_path(player_position, target_position)

	if path == null or path.is_empty():
		print("Unable to reach target")
		return

	# Only add target sprite if path exists
	var sprite = Sprite2D.new()
	sprite.texture = load("res://textures/target.png")
	sprite.global_position = position
	add_child(sprite)

# ===========================
# A* IMPLEMENTATION
# ===========================

func viewport_to_world_position(event_position: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * event_position
	
func calculate_path(agent_position: Vector2, target_position: Vector2):
	var start: Vector2i = local_to_map(agent_position)
	var goal: Vector2i = local_to_map(target_position)

	if not is_in_bounds(start) or not is_in_bounds(goal):
		return null

	if not is_walkable(goal):
		return null

	var open_set = [start]
	var came_from = {}

	var g_score = {}
	var f_score = {}

	g_score[start] = 0
	f_score[start] = distance(start, goal)

	while open_set.size() > 0:
		var current = open_set[0]
		for node in open_set:
			if f_score.get(node, INF) < f_score.get(current, INF):
				current = node

		if current == goal:
			return reconstruct_path(came_from, current)

		open_set.erase(current)

		for neighbor in get_neighbors(current):
			if not is_walkable(neighbor):
				continue

			var move_cost = (neighbor - current).length()
			var tentative_g = g_score.get(current, INF) + move_cost

			if tentative_g < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + distance(neighbor, goal)

				if neighbor not in open_set:
					open_set.append(neighbor)

	return null  # Not reachable


func distance(from: Vector2i, to: Vector2i) -> float:
	return Vector2(from).distance_to(Vector2(to))

func reconstruct_path(came_from, current):
	var path = [current]
	while current in came_from:
		current = came_from[current]
		path.insert(0, current)

	# Convert to world positions for movement
	var world_path = []
	for cell in path:
		world_path.append(map_to_local(cell))
	return world_path


func get_neighbors(cell: Vector2i):
	return [
		cell + Vector2i(1, 0),
		cell + Vector2i(-1, 0),
		cell + Vector2i(0, 1),
		cell + Vector2i(0, -1),
		# Diagonals
		cell + Vector2i(1, 1),
		cell + Vector2i(1, -1),
		cell + Vector2i(-1, 1),
		cell + Vector2i(-1, -1)
	]

func is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < map_width and cell.y >= 0 and cell.y < map_height
	
func is_walkable(cell: Vector2i) -> bool:
	return get_cell_source_id(FOREGROUND_LAYER, cell) == -1  # empty tile = walkable
