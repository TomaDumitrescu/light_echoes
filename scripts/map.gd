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
			elif map[x][y] == MapGenerator.EXIT:
				set_cell(FOREGROUND_LAYER, tile_position, EXIT_ID, Vector2i(0, 0), 1)
			
	for x in range(-1, map_width):	
		set_cell(FOREGROUND_LAYER, Vector2i(x, -1), ROCK_ID, Vector2i(0, 0))
		set_cell(FOREGROUND_LAYER, Vector2i(x, map_height), ROCK_ID, Vector2i(0, 0))
		
	for y in range(-1, map_height):	
		set_cell(FOREGROUND_LAYER, Vector2i(-1, y), ROCK_ID, Vector2i(0, 0))
		set_cell(FOREGROUND_LAYER, Vector2i(map_width, y), ROCK_ID, Vector2i(0, 0))
