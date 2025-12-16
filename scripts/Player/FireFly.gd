extends CharacterBody2D
class_name Player

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var trail_line: Line2D = $TrailLine 
@onready var sparkles: GPUParticles2D = $Sparkle
@onready var ui: CanvasLayer = $PlayerUI
@onready var next_level_timer: Timer = $NextLevelTimer
@onready var flying_sound: AudioStreamPlayer2D = $FlyingSound
@onready var transform_sound: AudioStreamPlayer2D = $TransformSound
@onready var lightSound: AudioStreamPlayer2D = $LightSound



var SPEED = 220.0 
@export var SPEED_LIGHT = 240.0 
@export var wave_frequency: float = 20.0 
@export var wave_amplitude: float = 40.0 
@export var wave_growth_speed: float = 8.0 


var particle_mode := true
var beam_mode := false
var is_transforming := false 
var aim_dir = Vector2.RIGHT 
var time_elapsed: float = 0.0
var slimed = false
var timer = 0.0
var path_history: Array = []
@export var SLIMED_TIMER = 5.0
@export var SLIME_EFFECT = Vector2(0.7, 10000)

var hearts_list: Array[TextureRect] = []
var health = 3
var dead = false

func _ready():
	add_to_group("player")

	if trail_line:
		trail_line.top_level = true
		trail_line.global_position = Vector2.ZERO
		trail_line.z_index = 100 
		trail_line.clear_points()


	if ui and ui.has_node("HealthBar"):
		var hearts_patent = ui.get_node("HealthBar")
		for child in hearts_patent.get_children():
			hearts_list.append(child)
	
	sprite.animation_finished.connect(_on_animation_finished)
	if flying_sound: flying_sound.play()

func _physics_process(delta):
	# Cambio de modo
	if Input.is_action_just_pressed("space") and not is_transforming:
		toggle_mode()

	if beam_mode:
		move_light(delta)
	else:
		move_particle()
	if slimed:
		velocity.x *= SLIME_EFFECT.x
		velocity.y += SLIME_EFFECT.y * delta
		timer -= delta
		if timer <= 0:
			slimed = false
			remove_status_effect("slimed")

	move_and_slide()
	
	if sparkles: sparkles.emitting = particle_mode

func move_particle():
	var input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	if input != Vector2.ZERO:
		aim_dir = input.normalized() 
		velocity = aim_dir * SPEED
		if not is_transforming: sprite.flip_h = !(input.x > 0)
	else:
		velocity = Vector2.ZERO
	
	if not is_transforming: sprite.play("flying")

func move_light(delta: float):
	if aim_dir == Vector2.ZERO: aim_dir = Vector2.RIGHT
	velocity = aim_dir * SPEED_LIGHT
	
	if trail_line:
		time_elapsed += delta
		var new_point_data = {
			"center_pos": global_position,     
			"normal": aim_dir.orthogonal(),     
			"spawn_time": time_elapsed          
		}
		path_history.push_front(new_point_data)
		
		if path_history.size() > 300:
			path_history.pop_back()

		trail_line.clear_points()
		
		for point_data in path_history:
			var age = time_elapsed - point_data["spawn_time"]

			var growth_factor = min(age * wave_growth_speed, 1.0)
			var current_wave = sin(point_data["spawn_time"] * wave_frequency) 
			var final_offset = current_wave * wave_amplitude * growth_factor
			var final_pos = point_data["center_pos"] + (point_data["normal"] * final_offset)
			trail_line.add_point(final_pos)

func toggle_mode():
	if particle_mode and aim_dir == Vector2.ZERO: aim_dir = Vector2.RIGHT

	particle_mode = !particle_mode
	beam_mode = !beam_mode
	is_transforming = true 
	if transform_sound: transform_sound.play()
	if beam_mode:
		sprite.play("to_light")
		time_elapsed = 0.0
		if flying_sound: flying_sound.stop()
		if lightSound: lightSound.play()    
		
		if trail_line: 
			trail_line.modulate.a = 1.0
			trail_line.clear_points()
			path_history.clear()
			var start_data = {
				"center_pos": global_position,
				"normal": aim_dir.orthogonal(),
				"spawn_time": 0.0
			}
			path_history.push_front(start_data)
			
	else:
		sprite.play("to_particle")
		if lightSound: lightSound.stop() 
		if flying_sound: flying_sound.play() 
		
		if trail_line:
			var tween = create_tween()
			tween.tween_property(trail_line, "modulate:a", 0.0, 0.2)
			tween.tween_callback(func():
				trail_line.clear_points()
				path_history.clear()
			)
	
	mode_transition(sprite)
	if sparkles: mode_transition(sparkles)

func _on_animation_finished():
	if sprite.animation == "to_light" or sprite.animation == "to_particle":
		is_transforming = false


func mode_transition(node: Node):
	node.scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(node, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func take_damage():
	if health > 1:
		health -= 1
		update_heart_display()
		get_tree().call_group("HUD", "damage_flash")
	else:
		die()

func die():
	if not dead:
		dead = true
		ScoreSaver.save_score(PlayerStats.score)
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func update_heart_display():
	if hearts_list.is_empty(): return
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health
	if health == 1: hearts_list[0].get_child(0).play("lowLife")
	else: hearts_list[0].get_child(0).play("idle")

func apply_status_effect(effect: String):
	if effect == "webbed": SPEED = SPEED/2
	if effect == "slimed": slimed = true; timer = SLIMED_TIMER

func remove_status_effect(effect: String):
	if effect == "webbed": SPEED = SPEED*2
	if effect == "slimed": pass

func go_to_next_level(): next_level_timer.start()
func _on_next_level_timer_timeout() -> void: get_tree().call_deferred("reload_current_scene")

# Getters
func is_particle_mode(): return particle_mode
func is_beam_mode(): return beam_mode
func get_beam_origin(): return global_position
func get_beam_direction(): return aim_dir

func _on_hitbox_body_entered(body: Node2D) -> void:
	if beam_mode:
		if body.is_in_group("enemies"):
			if body.has_method("die"):
				body.die()
			else:
				body.queue_free()
