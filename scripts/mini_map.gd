extends TileMap

@onready var camera: Camera2D = $"../Camera2D"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = camera.global_position - get_viewport_rect().size * 0.5
	pass
