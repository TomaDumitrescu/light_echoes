extends CharacterBody2D
class_name Player

const SPEED = 300.0
var particle_mode := false
var beam_mode := false

var aim_dir = Vector2.RIGHT #as default

func _process(delta):
	var input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	if input != Vector2.ZERO:
		velocity = input.normalized() * SPEED
		aim_dir = input.normalized() 
		
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	#witch mode
	if Input.is_action_just_pressed("space"):   # space for party
		particle_mode = !particle_mode
		beam_mode = false
		print("ParticleMode: ", particle_mode)

	if Input.is_action_just_pressed("shift"):   # shift for beam
		beam_mode = !beam_mode
		particle_mode = false
		print("BeamMode: ", beam_mode)
		
	update_beam()

func update_beam():
	var beam_line = $BeamLine
	if beam_mode:
		beam_line.visible = true
		var length = 300
		beam_line.global_position = global_position
		beam_line.points = [Vector2.ZERO, aim_dir * length]
	else:
		$BeamLine.visible = false
		
func is_particle_mode():
	return particle_mode

func is_beam_mode():
	return beam_mode

func get_beam_origin():
	return global_position
	
func get_beam_direction():
	return aim_dir
