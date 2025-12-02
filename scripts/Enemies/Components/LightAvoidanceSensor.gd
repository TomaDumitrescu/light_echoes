extends EnemyComponent
class_name LightAvoidance

var avoiding_beam = false
var flee_dir = Vector2.ZERO

func update(delta):
	var player = enemy_owner.player
	if not player:
		return
		
	if player.is_beam_mode():
		var dir = (enemy_owner.global_position - player.get_beam_origin()).normalized()
		var beam_dir = player.get_beam_direction().normalized()
		var dot = beam_dir.dot(dir)
		var angle_threshold = cos(deg_to_rad(20)) #10° tolerance
		
		flee_dir = dir.rotated(PI/2)
			
		if flee_dir != Vector2.ZERO and  dot >= angle_threshold:
			enemy_owner.velocity = flee_dir * enemy_owner.SPEED
	#
	#if player.is_beam_mode():
		#avoiding_beam = true
	#else:
		#avoiding_beam = false

		
func get_intended_state():
	if avoiding_beam:
		return { "state": enemy_owner.flee_state, "priority": 2 }
	return null
