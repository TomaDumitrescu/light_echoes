extends EnemyBase
class_name FlyingEnemy2

# --- Configuración ---
@export var FLY_SPEED: float = 150.0
@export var DASH_IMPULSE: float = 800.0
@export var ACCELERATION: float = 300.0
@export var ATTACK_RANGE_TRIGGER: float = 150.0 
@export var PERCEPTION_RANGE_VAL: float = 400.0
@export var IDLE_WAIT_TIME: float = 3.0
@export var DASH_COOLDOWN: float = 5.0

# --- Referencias ---
@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sfx_fly: AudioStreamPlayer2D = $FlyingSound
@onready var sfx_attack: AudioStreamPlayer2D = $AtackSound
@onready var sfx_die: AudioStreamPlayer2D = $BurnSound

var can_deal_damage: bool = true 

func _ready():
	super._ready()
	SPEED = FLY_SPEED
	ATTACK_RANGE = ATTACK_RANGE_TRIGGER
	PERCEPTION_RANGE = PERCEPTION_RANGE_VAL
	timer.wait_time = IDLE_WAIT_TIME
	
	# REACT_TO_BEAM: La polilla reacciona a la luz
	reactivity = Reactivity.REACT_TO_BEAM 
	
	attack_cooldown.wait_time = DASH_COOLDOWN 
	
	if not animated.animation_finished.is_connected(_on_animation_finished):
		animated.animation_finished.connect(_on_animation_finished)
	
	if sfx_fly: sfx_fly.play()

func perform_idle(delta):
	# Comportamiento de huida en reposo (se aleja del jugador)
	var direction_away = (global_position - player.global_position).normalized()
	var flee_speed = FLY_SPEED * 0.5
	var target_velocity = direction_away * flee_speed
	velocity = velocity.move_toward(target_velocity, ACCELERATION * delta)
	
	if velocity.x > 0:
		update_sprite_and_ray("flying", "right")
	else:
		update_sprite_and_ray("flying", "left")
		
	move_and_slide()
	check_body_collision()

func perform_chase(delta):
	var target_dir = (player.global_position - global_position).normalized()
	var dist_to_player = global_position.distance_to(player.global_position)
	
	# Intenta embestir (Dash) si está en rango y cooldown listo
	if attack_cooldown.is_stopped() and dist_to_player < ATTACK_RANGE:
		perform_dash_impulse(target_dir)
	
	# Movimiento de persecución estándar
	var desired_velocity = target_dir * FLY_SPEED
	velocity = velocity.move_toward(desired_velocity, ACCELERATION * delta)
	
	move_and_slide()
	check_body_collision()

	if animated.animation == "attack" and animated.is_playing():
		return 

	if target_dir.x > 0:
		update_sprite_and_ray("flying", "right")
	else:
		update_sprite_and_ray("flying", "left")

func perform_dash_impulse(dir):
	attack_cooldown.start()
	velocity = dir * DASH_IMPULSE
	
	if dir.x > 0:
		animated.flip_h = false
	else:
		animated.flip_h = true
		
	animated.play("attack")
	
	# Reproducir sonido de ataque si existe
	# if sfx_attack:
	# 	sfx_attack.pitch_scale = randf_range(0.9, 1.1)
	# 	sfx_attack.play()

func _on_animation_finished():
	if animated.animation == "attack":
		animated.play("flying")

func check_body_collision():
	if not can_deal_damage: return

	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		
		if collider and collider.is_in_group("player"):
			# AQUI ESTÁ EL CAMBIO PRINCIPAL:
			# Verifica si tiene el método Y si está en modo BEAM (Luz) 
			if collider.has_method("take_damage") and collider.is_beam_mode():
				can_deal_damage = false
				collider.take_damage()
				start_damage_interval()
				
				# Rebote fuerte tras golpear al jugador
				velocity = (global_position - collider.global_position).normalized() * 200
				return

func start_damage_interval():
	var tree = get_tree()
	if tree:
		await tree.create_timer(1.0).timeout
		can_deal_damage = true
	else:
		can_deal_damage = true

func perform_attack(delta):
	perform_chase(delta)

func die():
	set_physics_process(false)
	collision.set_deferred("disabled", true)
	PlayerStats.add_points(20)
	
	if sfx_fly: sfx_fly.stop()
	if sfx_die: sfx_die.play()
	
	animated.play("dying")
	if animated.sprite_frames.has_animation("dying"):
		await animated.animation_finished
	
	queue_free()
