extends EnemyBase
class_name JumpingEnemy

@export var JUMP_SPEED: float = 100
@export var JUMP_ATTACK_RANGE: float = 400
@export var JUMP_PERCEPTION_RANGE: float = 500
@export var WAIT_UNTIL_IDLE: float = 3
@export var JUMP_IMPULSE: float = 150
@export var GRAVITY: float = 10

const SLIME_BALL = preload("uid://cejyv8lbknxu6")
@export var THROW_FORCE := 2.0

func _ready():
	super._ready()
	SPEED = JUMP_SPEED
	ATTACK_RANGE = JUMP_ATTACK_RANGE
	PERCEPTION_RANGE = JUMP_PERCEPTION_RANGE
	timer.wait_time = WAIT_UNTIL_IDLE
	
	reactivity = Reactivity.REACT_TO_BEAM

	
func perform_idle(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity = Vector2.ZERO
	
	update_sprite_and_ray("idle","left")
	move_and_slide()

func perform_chase(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.x = direction.x * SPEED
		velocity.y = -JUMP_IMPULSE
	update_sprite_and_ray("chase","left")
	move_and_slide()

func perform_attack(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.x = direction.x * SPEED
		velocity.y = -JUMP_IMPULSE
		
	if attack_cooldown.is_stopped(): 
		shoot_slimeball()
		attack_cooldown.start()
	
	update_sprite_and_ray("attack","left")
	move_and_slide()

func shoot_slimeball():
	if SLIME_BALL == null:
		return
		
	var ball = SLIME_BALL.instantiate()
	get_tree().current_scene.add_child(ball)
	
	#start pos in front of enenmy
	ball.global_position = global_position + Vector2(direction.x * 10, -10)
	ball.shooter = self
	var p = player.global_position
	#distance
	var dx = p.x - global_position.x
	var dy = p.y - global_position.y
	#horizontal velocity
	var t = 0.6#throw time
	var vx = dx/t
	var vy = (dy + 0.5 * GRAVITY * t * t) / t
	ball.linear_velocity = Vector2(vx * THROW_FORCE,vy * THROW_FORCE)
