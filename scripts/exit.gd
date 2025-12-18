extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	animated_sprite_2d.play("default")
	
func _on_body_entered(body):
	if body is Player:
		body.go_to_next_level()
