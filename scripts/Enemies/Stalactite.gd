extends EnemyBase
class_name FallingEnemy

@export var FALL_SPEED: float = 500
@export var FALL_ATTACK_RANGE: float = 200
@export var FALL_PERCEPTION_RANGE: float = 500
@export var WAIT_UNTIL_IDLE: float = 3

@onready var visible_on_screen_enabler_2d: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D
@onready var coll: CollisionShape2D = $CollisionShape2D
@onready var sfx_fall: AudioStreamPlayer2D = $SfxFall
@onready var sfx_break: AudioStreamPlayer2D = $SfxBreak

var is_destroyed: bool = false
var has_started_falling: bool = false

func _ready():
	super._ready()
	SPEED = FALL_SPEED
	ATTACK_RANGE = FALL_ATTACK_RANGE
	PERCEPTION_RANGE = FALL_PERCEPTION_RANGE
	timer.wait_time = WAIT_UNTIL_IDLE
	reactivity = Reactivity.REACT_TO_PARTICLE

func perform_idle(delta):
	if has_started_falling:
		perform_attack(delta)
		return
	velocity = Vector2.ZERO
	sprite.play("idle")
	if player:
		direction = (player.global_position - global_position).normalized()
		ray.target_position = direction * PERCEPTION_RANGE
	move_and_slide()

func perform_chase(delta):
	if has_started_falling:
		perform_attack(delta)
		return

	if is_destroyed: return

	velocity = Vector2.ZERO
	sprite.play("falling")
	if player:
		direction = (player.global_position - global_position).normalized()
		ray.target_position = direction * PERCEPTION_RANGE
	move_and_slide()

func perform_attack(delta):
	if is_destroyed:
		return

	if not has_started_falling:
		has_started_falling = true
		sfx_fall.play()

	velocity = Vector2(0, SPEED)
	sprite.play("attack")
	
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		trigger_destruction(collision)

func trigger_destruction(collision):
	is_destroyed = true
	coll.set_deferred("disabled", true)
	
	var c = collision.get_collider()
	
	if c.is_in_group("player"):
		c.die()
	
	elif c.is_in_group("enemy") and visible_on_screen_enabler_2d.is_on_screen():
		PlayerStats.add_points(10)
		c.queue_free()
	
	sfx_break.play()
	sprite.play("destroy")
	await sprite.animation_finished
	queue_free()
