extends TileMap
class_name Map

const TILE_SIZE = 64

const BACKGROUND_LAYER = 0
const FOREGROUND_LAYER = 1

const ROCK_ID = 2
const BACKGROUND_ID = 3
const EXIT_ID = 4

var map_width = 0
var map_height = 0

const PLAYER_FREEDOM = 10
var floor_tiles = []

func create(map):
	clear()
	map_width = map.size()
	map_height = map[0].size()
	for x in range(map_width):
		for y in range(map_height):
			var tile_position = Vector2i(x, y)
			if map[x][y] == MapGenerator.WALL:
				set_cell(FOREGROUND_LAYER, tile_position, ROCK_ID, Vector2i(0, 0))
			elif map[x][y] == MapGenerator.FLOOR:
				set_cell(BACKGROUND_LAYER, tile_position, BACKGROUND_ID, Vector2i(0, 0))
				floor_tiles.append(tile_position)
			elif map[x][y] == MapGenerator.EXIT:
				set_cell(FOREGROUND_LAYER, tile_position, EXIT_ID, Vector2i(0, 0), 1)
			
	for x in range(-1, map_width):	
		set_cell(FOREGROUND_LAYER, Vector2i(x, -1), ROCK_ID, Vector2i(0, 0))
		set_cell(FOREGROUND_LAYER, Vector2i(x, map_height), ROCK_ID, Vector2i(0, 0))
		
	for y in range(-1, map_height):	
		set_cell(FOREGROUND_LAYER, Vector2i(-1, y), ROCK_ID, Vector2i(0, 0))
		set_cell(FOREGROUND_LAYER, Vector2i(map_width, y), ROCK_ID, Vector2i(0, 0))

func filter_markers(markers: Array[Vector2i], player_pos: Vector2i) -> Array[Vector2i]:
	var filtered_markers: Array[Vector2i] = []
	for marker in markers:
		if marker.distance_to(player_pos) <= PLAYER_FREEDOM:
			continue
		filtered_markers.append(marker)

	return filtered_markers

func add_air_elements(air_markers: Array[Vector2i], player_pos: Vector2i):
	var filtered_markers = filter_markers(air_markers, player_pos)
	# DEBUG visualize
	#for air_marker in filtered_markers:
		#set_cell(BACKGROUND_LAYER, air_marker, -1, Vector2i(-1, -1), -1)

func add_ground_elements(ground_markers: Array[Vector2i], player_pos: Vector2i):
	var filtered_markers = filter_markers(ground_markers, player_pos)
	# DEBUG visualize
	#for ground_marker in filtered_markers:
		#set_cell(BACKGROUND_LAYER, ground_marker, -1, Vector2i(-1, -1), -1)

func add_ceiling_elements(ceiling_markers: Array[Vector2i], player_pos: Vector2i):
	var filtered_markers = filter_markers(ceiling_markers, player_pos)
	# DEBUG visualize
	#for ceiling_marker in filtered_markers:
		#set_cell(BACKGROUND_LAYER, ceiling_marker, -1, Vector2i(-1, -1), -1)

func add_side_elements(side_markers: Array[Vector2i], player_pos: Vector2i):
	var filtered_markers = filter_markers(side_markers, player_pos)
	# DEBUG visualize
	#for side_marker in filtered_markers:
		#set_cell(BACKGROUND_LAYER, side_marker, -1, Vector2i(-1, -1), -1)

func add_corner_elements(lava_markers: Array[Vector2i]):
		#for side_marker in lava_markers:
			#set_cell(BACKGROUND_LAYER, side_marker, -1, Vector2i(-1, -1), -1)
		return
