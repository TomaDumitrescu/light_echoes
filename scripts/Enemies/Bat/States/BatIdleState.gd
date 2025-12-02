extends EnemyState
class_name BatIdleState

func enter(prev_state):
	print("Enter IdleState")
	owner.velocity = Vector2.ZERO

func update(delta):
	pass #state change automatically over intent

func exit(next_state):
	print("Exiting IdleState")
	owner.velocity = Vector2.ZERO
