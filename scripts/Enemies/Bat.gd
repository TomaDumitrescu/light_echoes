extends EnemyBase
class_name FlyingEnemy

@export var FLY_SPEED: float = 200
@export var FLY_ATTACK_RANGE: float = 80
@export var FLY_PERCEPTION_RANGE: float = 300
@export var WAIT_UNTIL_IDLE: float = 3
@onready var animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	super._ready()
	SPEED = FLY_SPEED
	ATTACK_RANGE = FLY_ATTACK_RANGE
	PERCEPTION_RANGE = FLY_PERCEPTION_RANGE
	timer.wait_time = WAIT_UNTIL_IDLE
	
	reactivity = Reactivity.REACT_TO_PARTICLE
	
func perform_idle(delta):
	if player.is_beam_mode():
		velocity = velocity.move_toward(-direction * SPEED, 100 * delta)
	else:	
		velocity = Vector2.ZERO
	update_sprite_and_ray("flying", "left")
	move_and_slide()

func perform_chase(delta):
	velocity = velocity.move_toward(direction * SPEED, 100 * delta)
	update_sprite_and_ray("flying", "left")
	move_and_slide()

func perform_attack(delta):
	if not attack_cooldown.is_stopped():
		velocity = Vector2.ZERO	 #fly without attack
		return
	bite()
	attack_cooldown.start()
	velocity = velocity.move_toward(direction * SPEED, 200 * delta)
	update_sprite_and_ray("attack", "left")

	move_and_slide()
	
func bite():
	player.take_damage()
	
func die():
	set_physics_process(false)
	collision.set_deferred("disabled", true)
	PlayerStats.add_points(20)
	animated.play("dying")
	await sprite.animation_finished
	
	queue_free()
	
