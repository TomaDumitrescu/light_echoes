extends CharacterBody2D
class_name Player

const SPEED = 15000.0

func _physics_process(delta):
	var direction = Input.get_vector("ui_left","ui_right","ui_up", "ui_down")
	if direction.x == 0 and direction.y == 0:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = direction.x * SPEED * delta
		velocity.y = direction.y * SPEED * delta
	
	move_and_slide()
