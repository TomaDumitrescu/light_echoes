@tool
extends Area2D

@onready var texture_rect: TextureRect = $TextureRect
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var speed: Vector3 = Vector3(0,50,10)
var off: Vector3 = Vector3.ZERO
var bodies_in_lava = []

func _ready() -> void:
	bodies_in_lava = []
	animated_sprite_2d.play("default")

func _process(delta: float) -> void:
	off += speed * delta
	texture_rect.texture.noise.offset = off
	
	for body in bodies_in_lava:
		print(body, " drowns in lava" )


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		bodies_in_lava.append(body)
		body.die()
	if body.is_in_group("enemy") and body.is_visible_on_screen:
		body.queue_free()
		print("Lava killed enemy (+10 points)")
		PlayerStats.add_points(10)


func _on_body_exited(body: Node2D) -> void:
	bodies_in_lava.erase(body)
