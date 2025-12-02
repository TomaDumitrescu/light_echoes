extends Enemy
class_name Bat

var SPEED: float = 200.0
var alerted_by_sound: bool = false

#states
var idle_state: EnemyState
var chase_state: EnemyState
var flee_state: EnemyState


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_component(SoundSensor.new())
	add_component(LightAvoidance.new())
	
	idle_state = BatIdleState.new()
	chase_state = BatChaseState.new()
	flee_state = BatFleeState.new()
	
	change_state(idle_state)
	
	#ready in Enemy
	super._ready()
