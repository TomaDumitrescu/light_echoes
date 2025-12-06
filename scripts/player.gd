extends CharacterBody2D
class_name Player

const SPEED = 20000.0
@onready var next_level_timer: Timer = $NextLevelTimer

func _physics_process(delta):
	var direction = Input.get_vector("ui_left","ui_right","ui_up", "ui_down")
	if direction.x == 0 and direction.y == 0:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = direction.x * SPEED * delta
		velocity.y = direction.y * SPEED * delta
	move_and_slide()
	
func go_to_next_level():
	next_level_timer.start()
	
func _on_next_level_timer_timeout():
	get_tree().call_deferred("reload_current_scene")
