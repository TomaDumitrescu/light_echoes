extends Node	#Node bc needs areas, timer, child nodes,...
class_name EnemyComponent

var enemy_owner: Enemy = null #set from enemy

func on_ready() -> void:
	pass
	
func update(delta: float) -> void:
	pass
	
func get_intended_state():
	return null
