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
@onready var rebote_sound: AudioStreamPlayer2D = $ReboteSound
@onready var mirror_rebote_sound: AudioStreamPlayer2D = $MirrorReboteSound

@export var BASE_SPEED: float = 220.0

@export var wave_frequency: float = 20.0 
@export var wave_amplitude: float = 40.0 
@export var wave_growth_speed: float = 8.0 

var SPEED 
var SPEED_LIGHT 
var particle_mode := true
var beam_mode := false
var is_transforming := false 
var aim_dir = Vector2.RIGHT 
var time_elapsed: float = 0.0
var slimed = false
var slimed_timer: float = 0.0
var fast = false
var speed_timer: float = 0.0
var path_history: Array = []
var current_gravity: float = 0.0

@export var SPEED_TIMER = 5.0
@export var SLIMED_TIMER = 5.0

@export var SLIME_GRAVITY: float = 6000.0
@export var WEBBED_MULT: float = 0.5
@export var SPEED_MULT: float = 1.5

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
	
	SPEED = BASE_SPEED 
	SPEED_LIGHT = BASE_SPEED 

func _physics_process(delta):
	# Cambio de modo
	if Input.is_action_just_pressed("space") and not is_transforming:
		toggle_mode()
		
	if slimed:
		slimed_timer -= delta
		if slimed_timer <= 0:
			remove_status_effect("slimed")
	
	if fast:
		speed_timer -= delta
		if speed_timer <= 0:
			remove_status_effect("speedy")
			
	if beam_mode:
		move_light(delta)
	else:
		move_particle()
	
	if particle_mode:
		apply_gravity(delta)
		
	move_and_slide()
	
	if beam_mode and get_slide_collision_count() > 0:
		handle_beam_reflection()
	
	if sparkles: sparkles.emitting = particle_mode

func apply_gravity(delta):
	velocity.y += current_gravity * delta
	
func move_particle():
	var input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	sprite.rotation = 0
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
	sprite.rotation = aim_dir.angle()
	
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

func recalc_effects():
	SPEED = BASE_SPEED
	SPEED_LIGHT = BASE_SPEED
	current_gravity = 0.0
	
	if PlayerStats.has_effect("webbed"):
		SPEED *= WEBBED_MULT
		SPEED_LIGHT *= WEBBED_MULT
		
	if PlayerStats.has_effect("slimed"):
		current_gravity = SLIME_GRAVITY
		
	if PlayerStats.has_effect("speedy"):
		SPEED_LIGHT *= SPEED_MULT
		
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
		if ui and ui.has_method("damage_flash"):
			ui.damage_flash()
	else:
		die()

func die():
	if not dead:
		dead = true
		ScoreSaver.save_score(PlayerStats.score, PlayerStats.current_level)
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func update_heart_display():
	if hearts_list.is_empty(): return
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < health
	if health == 1: hearts_list[0].get_child(0).play("lowLife")
	else: hearts_list[0].get_child(0).play("idle")

func apply_status_effect(effect: String):
	if not PlayerStats.has_effect(effect):
		PlayerStats.add_effect(effect)
		
	if effect == "webbed": 
		pass	#handled by recalc_effects()
	
	if effect == "speedy":
		fast = true
		speed_timer = SPEED_TIMER
		
	if effect == "slimed": 
		slimed = true
		slimed_timer = SLIMED_TIMER
		
	recalc_effects()

func remove_status_effect(effect: String):
	if PlayerStats.has_effect(effect):
		PlayerStats.remove_effect(effect)
		
	if effect == "webbed": 
		pass	#handled by recalc_effects()
	
	if effect == "speedy":
		fast = false
		speed_timer = 0.0
		
	if effect == "slimed": 
		slimed = false
		slimed_timer = 0.0
	
	recalc_effects()

func go_to_next_level(): next_level_timer.start()
func _on_next_level_timer_timeout() -> void: 
	PlayerStats.add_level()
	get_tree().call_deferred("reload_current_scene")

# Getters
func is_particle_mode(): return particle_mode
func is_beam_mode(): return beam_mode
func get_beam_origin(): return global_position
func get_beam_direction(): return aim_dir

func handle_beam_reflection():
	var collision = get_slide_collision(0)
	var collider = collision.get_collider()
	var normal = collision.get_normal()
	
	if collider.is_in_group("projectiles"):
		return
		
	if not collider.is_in_group("enemies"):
		aim_dir = aim_dir.bounce(normal)
		velocity = velocity.bounce(normal)
		sprite.rotation = aim_dir.angle()
		
		if collider.is_in_group("mirrors"):
			mirror_rebote_sound.play()
			apply_status_effect("speedy")
		else:
			rebote_sound.play()
			
		global_position += aim_dir * 2.0

func _on_hitbox_body_entered(body: Node2D) -> void:
	if beam_mode:	
		if body.is_in_group("enemies") and body.reactivity == 1: #body.reac == 1 is reactive to particle -> burn if light
			if body.has_method("die"):
				body.die()
			else:
				body.queue_free()
