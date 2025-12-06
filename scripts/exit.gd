extends Area2D

func _on_body_entered(body):
	if body is Player:
		body.go_to_next_level()
