extends Resource	#not Node s.t. referencing works
class_name EnemyState

var owner: Enemy = null #reference to enemy currently using state

#if enemy switches to state
func enter(prev_state) -> void:
	pass

func update(delta: float) -> void:
	pass
	
#switch out of state
func exit(next_state) -> void:
	pass
