extends TileMap
class_name MiniMap

const LAYER = 0
const TILE_ID = 0
const REVEAL_RADIUS = 9

@onready var camera: Camera2D = $"../Camera2D"
@onready var tilemap: Map = $"../TileMap"
@onready var player: Player = $"../FireFly"

var explored = []

func init_explored(map_width: int, map_height: int):
	explored.clear()
	for x in range(map_width):
		explored.append([])
		for y in range(map_height):
			explored[x].append(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = camera.global_position + get_viewport_rect().size * Vector2(0.25, 0.05)
	update_map()
	
func update_map():
	var player_global_position = player.global_position
	reveal_area(player_global_position)

func reveal_area(player_global_position: Vector2):
	var center = tilemap.local_to_map(tilemap.to_local(player_global_position))

	for dx in range(-REVEAL_RADIUS, REVEAL_RADIUS + 1):
		for dy in range(-REVEAL_RADIUS, REVEAL_RADIUS + 1):
			var tile = Vector2i(center.x + dx, center.y + dy)

			# Circle check (optional)
			if dx * dx + dy * dy > REVEAL_RADIUS * REVEAL_RADIUS:
				continue

			reveal_tile_at(tile)

func reveal_tile_at(tile: Vector2i):
	if tile.x < 0 or tile.x >= tilemap.map_width: return
	if tile.y < 0 or tile.y >= tilemap.map_height: return

	if explored[tile.x][tile.y]:
		return  # already revealed

	explored[tile.x][tile.y] = true

	# Get what kind of tile this is
	var fg = tilemap.get_cell_source_id(Map.FOREGROUND_LAYER, tile)

	if fg == Map.ROCK_ID:
		set_cell(LAYER, tile, TILE_ID, Vector2i(0,0))
