extends EnemyState
class_name BatChaseState

@export var stop_chase_dis: float = 300.0

func enter(prev_state):
	print("Entering ChaseState")
	
func update(delta):
	var player = owner.player
	
	#player in particle mode or distanced -> idle
	if not player.is_particle_mode() or owner.global_position.distance_to(player.global_position) > stop_chase_dis:
		owner.change_state(owner.idle_state)
		return
		
	#else move towards player
	var dir = (player.global_position - owner.global_position).normalized()
	owner.velocity = dir * owner.SPEED

func exit(next_state):
	print("Exiting ChaseState")
	owner.velocity = Vector2.ZERO
