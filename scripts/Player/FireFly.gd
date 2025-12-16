extends CharacterBody2D
class_name Player

# --- REFERENCIAS ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var trail_line: Line2D = $TrailLine 
@onready var sparkles: GPUParticles2D = $Sparkle
@onready var ui: CanvasLayer = $PlayerUI
@onready var next_level_timer: Timer = $NextLevelTimer

# --- CONFIGURACIÓN ---
var SPEED = 220.0 
@export var SPEED_LIGHT = 240.0 
@export var wave_frequency: float = 20.0 
@export var wave_amplitude: float = 50.0 # Aumentado para que se note la curva

# --- ESTADOS ---
var particle_mode := true
var beam_mode := false
var is_transforming := false 
var aim_dir = Vector2.RIGHT 
var time_elapsed: float = 0.0
var slimed = false
var timer = 0.0
@export var SLIMED_TIMER = 5.0
@export var SLIME_EFFECT = Vector2(0.7, 10000)

# --- SALUD ---
var hearts_list: Array[TextureRect] = []
var health = 3
var dead = false

func _ready():
	add_to_group("player")

	if trail_line:
		trail_line.top_level = true
		trail_line.global_position = Vector2.ZERO
		trail_line.z_index = 100 
		trail_line.width = 30.0
		trail_line.default_color = Color.RED 
		trail_line.clear_points()
	else:
		print("ERROR CRITICO: No se encuentra el nodo TrailLine en el Player")

	if ui and ui.has_node("HealthBar"):
		var hearts_patent = ui.get_node("HealthBar")
		for child in hearts_patent.get_children():
			hearts_list.append(child)
	
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	# Cambio de modo
	if Input.is_action_just_pressed("space") and not is_transforming:
		toggle_mode()

	if beam_mode:
		move_light(delta)
	else:
		move_particle()
			
	# Slimed logic
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
	# Aseguramos que aim_dir no sea cero
	if aim_dir == Vector2.ZERO: aim_dir = Vector2.RIGHT
		
	velocity = aim_dir * SPEED_LIGHT
	
	# --- GENERACIÓN DEL TRAIL ---
	if trail_line:
		time_elapsed += delta
		
		# Matemática de la onda
		var wave_offset = sin(time_elapsed * wave_frequency) * wave_amplitude
		var perp_direction = aim_dir.orthogonal() # Dirección a los lados (90 grados)
		
		# Calculamos dónde dibujar el punto
		# offset_atras: Mueve el punto de spawn a la cola del personaje
		var offset_atras = aim_dir * 20.0 
		var spawn_pos = global_position - offset_atras
		
		# Punto final con la oscilación
		var final_point = spawn_pos + (perp_direction * wave_offset)
		
		trail_line.add_point(final_point)
		
		# Debug en consola: Si ves esto, el código se ejecuta
		# print("Pintando en: ", final_point) 
		
		# Limitar longitud (Cola más larga = 300 puntos)
		if trail_line.get_point_count() > 300:
			trail_line.remove_point(0)

func toggle_mode():
	if particle_mode and aim_dir == Vector2.ZERO: aim_dir = Vector2.RIGHT
		
	particle_mode = !particle_mode
	beam_mode = !beam_mode
	is_transforming = true 
	
	if beam_mode:
		sprite.play("to_light")
		time_elapsed = 0.0
		if trail_line:
			trail_line.clear_points()
			# Punto inicial "pegado" al personaje para empezar el trazo
			trail_line.add_point(global_position)
	else:
		sprite.play("to_particle")
	
	mode_transition(sprite)
	if sparkles: mode_transition(sparkles)

func _on_animation_finished():
	if sprite.animation == "to_light" or sprite.animation == "to_particle":
		is_transforming = false

# Funciones auxiliares sin cambios
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
