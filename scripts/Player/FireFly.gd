extends CharacterBody2D
class_name Player

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var next_level_timer: Timer = $NextLevelTimer
@onready var ui: CanvasLayer = $PlayerUI
@onready var sparkles: GPUParticles2D = $Sparkle

@export var SLIMED_TIMER = 5.0
@export var SLIME_EFFECT = Vector2(0.7, 10000)
var SPEED = 300.0
var particle_mode := true
var beam_mode := false

var aim_dir = Vector2.RIGHT #as default
var slimed = false
var timer

var hearts_list: Array[TextureRect]
var health = 3

var dead = false

func _ready():
	add_to_group("player")
	var hearts_patent = ui.get_node("HealthBar")
	for child in hearts_patent.get_children():
		hearts_list.append(child)
	
func _process(delta):
	sprite.play("flying")
	var input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	if input != Vector2.ZERO:
		sprite.flip_h = !(input.x > 0)
		velocity = input.normalized() * SPEED
		aim_dir = input.normalized() 
		
	else:
		velocity = Vector2.ZERO
		
	if particle_mode:
		sparkles.emitting = true
	else:
		sparkles.emitting = false
		
	if slimed:
		velocity.x *= SLIME_EFFECT.x
		velocity.y += SLIME_EFFECT.y * delta
		timer -= delta
		if timer <= 0:
			slimed = false
			timer = SLIMED_TIMER
			remove_status_effect("slimed")
	move_and_slide()

	if Input.is_action_just_pressed("space"):   # space for party
		particle_mode = !particle_mode
		beam_mode = !beam_mode
		
		if(beam_mode):
			sprite.play("to_particle")
			print("Animacion 2")
		else:
			sprite.play("to_light")
			print("Animacion 1")
		
			
		mode_transition(sprite)
		if sparkles: 
			mode_transition(sparkles)
		print("ParticleMode: ", particle_mode, "| BeamMode: ", beam_mode)

func mode_transition(node: Node):
	node.scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(node, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func is_particle_mode():
	return particle_mode

func is_beam_mode():
	return beam_mode

func get_beam_origin():
	return global_position
	
func get_beam_direction():
	return aim_dir
	
func take_damage():
	if health > 1:
		health -= 1
		update_heart_display()
	else:
		die()

func die():
	if not dead:
		dead = true
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health
	
	if health == 1:
		hearts_list[0].get_child(0).play("lowLife")
	else:
		hearts_list[0].get_child(0).play("idle")
	
func apply_status_effect(effect: String):
	if (effect == "webbed"):
		SPEED = SPEED/2
		PlayerStats.add_effect("webbed")
	if (effect == "slimed"):
		slimed = true
		timer = SLIMED_TIMER
		PlayerStats.add_effect("slimed")
		
func remove_status_effect(effect: String):
	if (effect == "webbed"):
		SPEED = SPEED*2
		PlayerStats.remove_effect("webbed")
	if (effect == "slimed"):
		PlayerStats.remove_effect("slimed")
		
func go_to_next_level():
	next_level_timer.start()
	
func _on_next_level_timer_timeout() -> void:
	get_tree().call_deferred("reload_current_scene")
