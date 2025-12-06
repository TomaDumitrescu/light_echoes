class_name MapGenerator
extends Node

const WALL := 1
const FLOOR := 0
const EXIT := 2

@export var width := 64
@export var height := 64
@export var random_fill_percent := 45
@export var smoothing_iterations := 5
@export var room_threshold := 50
@export var wall_threshold := 50

var map := []

func get_empty_cell() -> Vector2i: 
	var col = randi_range(0, width-1) 
	var row = randi_range(0, height-1) 
	while(not is_walkable(col, row)): 
		col = randi_range(0, width-1) 
		row = randi_range(0, height-1) 
	return Vector2i(col, row)
	
func is_walkable(col: int, row: int) -> bool: 
	return map[col][row] == FLOOR # empty tile = walkable

func generate_map() -> void:
	map = []
	random_fill()
	for i in smoothing_iterations:
		smooth_map()
	process_map()
	add_exit()
	
func add_exit():
	var cell = get_empty_cell()
	map[cell.x][cell.y] = EXIT

# ----------------------------------------
# RANDOM FILL
# ----------------------------------------
func random_fill() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	for x in range(width):
		map.append([])
		for y in range(height):

			# Border walls
			if x == 0 or y == 0 or x == width-1 or y == height-1:
				map[x].append(WALL)
			elif rng.randi_range(0,100) < random_fill_percent:
				map[x].append(WALL)
			else:
				map[x].append(FLOOR)

# ----------------------------------------
# SMOOTHING (Cellular Automata)
# ----------------------------------------
func smooth_map() -> void:
	var new_map = []
	for x in range(width):
		new_map.append([])
		for y in range(height):
			var neighbors = get_surrounding_wall_count(x, y)

			if neighbors > 4:
				new_map[x].append(WALL)
			elif neighbors < 4:
				new_map[x].append(FLOOR)
			else:
				new_map[x].append(map[x][y])

	map = new_map


func get_surrounding_wall_count(x: int, y: int) -> int:
	var count = 0
	for nx in range(x-1, x+2):
		for ny in range(y-1, y+2):
			if nx == x and ny == y: continue
			if not is_in_map(nx, ny, width, height):
				count += 1
			else:
				count += map[nx][ny]
	return count


static func is_in_map(x: int, y: int, width: int, height: int) -> bool:
	return x >= 0 and x < width and y >= 0 and y < height

# ----------------------------------------
# REGION DETECTION
# ----------------------------------------
func process_map() -> void:
	var wall_regions = get_regions(WALL)
	for region in wall_regions:
		if region.size() < wall_threshold:
			_for_each_tile(region, FLOOR)

	var room_regions = get_regions(FLOOR)
	var surviving_rooms = []

	for region in room_regions:
		if region.size() < room_threshold:
			_for_each_tile(region, WALL)
		else:
			surviving_rooms.append(Room.new(region, map, width, height))

	surviving_rooms.sort_custom(func(a, b): return b.room_size - a.room_size)

	if surviving_rooms.size() == 0:
		return

	surviving_rooms[0].is_main_room = true
	surviving_rooms[0].is_accessible = true

	connect_closest_rooms(surviving_rooms)


func _for_each_tile(region: Array, value: int):
	for p in region:
		map[p.x][p.y] = value


func get_regions(tile_type: int) -> Array:
	var regions = []
	var flags = []
	for x in range(width):
		flags.append([])
		for y in range(height):
			flags[x].append(false)

	for x in range(width):
		for y in range(height):
			if not flags[x][y] and map[x][y] == tile_type:
				var region = get_region_tiles(x, y, flags)
				regions.append(region)

	return regions


func get_region_tiles(start_x: int, start_y: int, flags) -> Array:
	var region = []
	var tile_type = map[start_x][start_y]

	var q = []
	q.append(Vector2i(start_x, start_y))
	flags[start_x][start_y] = true

	while q.size() > 0:
		var tile = q.pop_front()
		region.append(tile)

		for nx in range(tile.x-1, tile.x+2):
			for ny in range(tile.y-1, tile.y+2):
				if is_in_map(nx, ny, width, height) and (nx == tile.x or ny == tile.y):
					if not flags[nx][ny] and map[nx][ny] == tile_type:
						flags[nx][ny] = true
						q.append(Vector2i(nx, ny))

	return region


# ----------------------------------------
# ROOM + CONNECTIONS
# ----------------------------------------
func connect_closest_rooms(rooms: Array, force_main := false):
	var room_list_a = []
	var room_list_b = []

	if force_main:
		for r in rooms:
			if r.is_accessible:
				room_list_b.append(r)
			else:
				room_list_a.append(r)
	else:
		room_list_a = rooms
		room_list_b = rooms

	var best_a
	var best_b
	var best_tile_a
	var best_tile_b
	var best_dist := 999999
	var found = false

	for room_a in room_list_a:
		if not force_main and room_a.connected_rooms.size() > 0:
			continue

		for room_b in room_list_b:
			if room_a == room_b or room_a.is_room_connected(room_b):
				continue

			for ta in room_a.edge_tiles:
				for tb in room_b.edge_tiles:
					var d = (ta.x - tb.x) * (ta.x - tb.x) + (ta.y - tb.y) * (ta.y - tb.y)
					if d < best_dist or not found:
						best_dist = d
						found = true
						best_a = room_a
						best_b = room_b
						best_tile_a = ta
						best_tile_b = tb

		if found and not force_main:
			create_passage(best_a, best_b, best_tile_a, best_tile_b)

	if found and force_main:
		create_passage(best_a, best_b, best_tile_a, best_tile_b)
		connect_closest_rooms(rooms, true)


func create_passage(room_a, room_b, tile_a: Vector2i, tile_b: Vector2i):
	Room.connect_rooms(room_a, room_b)
	var line = get_line(tile_a, tile_b)
	for p in line:
		draw_circle(p, 3)


func draw_circle(center: Vector2i, r: int):
	for dx in range(-r, r):
		for dy in range(-r, r):
			if dx*dx + dy*dy <= r*r:
				var x = center.x + dx
				var y = center.y + dy
				if is_in_map(x,y, width, height):
					map[x][y] = FLOOR


func get_line(a: Vector2i, b: Vector2i) -> Array:
	var line = []
	var x = a.x
	var y = a.y
	var dx = b.x - a.x
	var dy = b.y - a.y

	var inverted = false
	var step = sign(dx)
	var gradient_step = sign(dy)
	var longest = abs(dx)
	var shortest = abs(dy)

	if longest < shortest:
		inverted = true
		longest = abs(dy)
		shortest = abs(dx)
		step = sign(dy)
		gradient_step = sign(dx)

	var grad = longest / 2

	for i in longest:
		line.append(Vector2i(x, y))
		if inverted: y += step
		else: x += step

		grad += shortest
		if grad >= longest:
			if inverted: x += gradient_step
			else: y += gradient_step
			grad -= longest

	return line


# ----------------------------------------
# ROOM CLASS
# ----------------------------------------
class Room:
	var tiles := []
	var edge_tiles := []
	var connected_rooms := []
	var room_size := 0
	var is_accessible := false
	var is_main_room := false

	func _init(tile_list: Array, map: Array, width: int , height: int):
		tiles = tile_list
		room_size = tiles.size()

		for t in tiles:
			for x in range(t.x-1, t.x+2):
				for y in range(t.y-1, t.y+2):
					if MapGenerator.is_in_map(x, y, width, height) and (x == t.x or y == t.y):
						if map[x][y] == WALL:
							edge_tiles.append(t)

	func set_accessible():
		if not is_accessible:
			is_accessible = true
			for r in connected_rooms:
				r.set_accessible()

	static func connect_rooms(a, b):
		if a.is_accessible:
			b.set_accessible()
		elif b.is_accessible:
			a.set_accessible()

		a.connected_rooms.append(b)
		b.connected_rooms.append(a)

	func is_room_connected(other):
		return other in connected_rooms

