extends StaticBody2D

@onready var area: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var det: Area2D = $DetectionArea
@onready var coll: CollisionShape2D = $CollisionShape2D

@export var grow_speed = 1.0
@export var max_scale = 2.0
@export var min_scale = 1.0

var current_scale = 1.0
var is_growing = false
var total_frames = 4
var player = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	total_frames = sprite.sprite_frames.get_frame_count("growing")
	
func _process(delta: float) -> void:
	if not player: 
		print("No player found!")
		
	if is_growing and player.is_beam_mode():
		current_scale = min(current_scale + grow_speed * delta, max_scale)
	else:
		current_scale = max(current_scale - grow_speed * delta, min_scale)
	
	update_animation()
	#height of current frame
	var tex = sprite.sprite_frames.get_frame_texture("growing", sprite.frame)
	var sprite_height = tex.get_height()
	
	sprite.scale = Vector2(current_scale, current_scale)	#3 as width of plant
	sprite.position = Vector2(0, - (sprite_height * (current_scale - 1)) / 2.0) #fixed position
	
	update_collider(sprite_height)
	
	
func update_animation():
	var progress = (current_scale - min_scale) / (max_scale - min_scale)
	sprite.animation = "growing"
	var frame_idx = int(progress * (total_frames - 1))	
	sprite.frame = frame_idx

func update_collider(h: float):
	var shape = coll.shape as RectangleShape2D
	shape.size.y = h * current_scale
	coll.shape = shape
	coll.position.y = -shape.size.y/2.0


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_growing = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_growing = false
