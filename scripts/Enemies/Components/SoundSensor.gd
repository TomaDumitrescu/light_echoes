extends EnemyComponent
class_name SoundSensor

@export var acoustic_radius: float = 200.0

func update(delta):
	var player = enemy_owner.player
	if player.is_particle_mode():
		var dir = (player.global_position - enemy_owner.global_position).normalized()
		enemy_owner.velocity = dir * enemy_owner.SPEED
		
	else: 
		enemy_owner.velocity = Vector2.ZERO
	#if not player:
		#return
	#
	#if player.is_particle_mode() and enemy_owner.global_position.distance_to(player.global_position) < acoustic_radius:
		#enemy_owner.alerted_by_sound = true
	#else:
		#enemy_owner.alerted_by_sound = false

func get_intended_state():
	if enemy_owner.alerted_by_sound:
		return { "state": enemy_owner.chase_state, "priority": 3 } 
	return null
