extends EnemyState
class_name BatFleeState

var flee_dir: Vector2 = Vector2.ZERO

func enter(prev_state):
	print("Entering FleeState")
	if owner.player:
		var dir = (owner.global_position - owner.player.get_beam_origin()).normalized()
		if randf() < 0.5:
			flee_dir = dir.rotated(PI/2)
		else: 
			flee_dir = dir.rotated(-PI/2)
			
func update(delta):
	if flee_dir != Vector2.ZERO:
		owner.velocity = flee_dir * owner.SPEED

func exit(next_state):
	print("Exiting FleeState")
	owner.velocity = Vector2.ZERO
	flee_dir = Vector2.ZERO
