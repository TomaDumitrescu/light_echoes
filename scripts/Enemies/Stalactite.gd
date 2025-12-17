extends EnemyBase
class_name FallingEnemy

@export var FALL_SPEED: float = 500
@export var FALL_ATTACK_RANGE: float = 200
@export var FALL_PERCEPTION_RANGE: float = 500
@export var WAIT_UNTIL_IDLE: float = 3

@onready var coll: CollisionShape2D = $CollisionShape2D

func _ready():
	super._ready()
	SPEED = FALL_SPEED
	ATTACK_RANGE = FALL_ATTACK_RANGE
	PERCEPTION_RANGE = FALL_PERCEPTION_RANGE
	timer.wait_time = WAIT_UNTIL_IDLE
	
	reactivity = Reactivity.REACT_TO_PARTICLE
	
func perform_idle(delta):
	velocity = Vector2.ZERO
	sprite.play("idle")
	direction = (player.global_position - global_position).normalized()
	ray.target_position = direction  * PERCEPTION_RANGE
	move_and_slide()

func perform_chase(delta):
	velocity = Vector2.ZERO
	sprite.play("falling")
	direction = (player.global_position - global_position).normalized()
	ray.target_position = direction * PERCEPTION_RANGE
	move_and_slide()

func perform_attack(delta):
	velocity = Vector2(0, SPEED)
	sprite.play("attack")
	var collision = move_and_collide(velocity * delta)
	if collision:
		var c = collision.get_collider()
		if c.is_in_group("player"):
			c.die()
		if c.is_in_group("enemy") and c.is_visible_on_screen:
			print("stac hit enemy (+10 points)")
			PlayerStats.add_points(10)
			c.queue_free()
			queue_free()
		else:
			queue_free()
