extends CharacterBody2D
class_name Enemy

var components = [] #list of all comp
var current_state = null #one object
var player
var home_pos: Vector2


# called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	if not player:
		print("Player not found!")
	home_pos = global_position
	
	#create enemy by activating components
	for c in components:
		c.enemy_owner = self	#state gets ref to controlling enemy
		c.on_ready()

func _physics_process(delta: float) -> void:
	var intended_state = null
	for c in components:
		var s = c.get_intended_state()
		if s != null: 
			if s.state != current_state:
				change_state(s.state)
			break
				
	for c in components:
		c.update(delta)
	
	move_and_slide()

func add_component(component):
	components.append(component)
	
func change_state(new_state):
	if new_state == null:
		return
	if current_state:
		current_state.exit(new_state)
	var prev_state = current_state
	current_state = new_state
	current_state.owner = self
	current_state.enter(prev_state)
	
func has_component(type_name: String) -> bool: 
	for c in components: 
		if c.get_class() == type_name: 
			return true
	return false 
	
func get_component(type_name: String): 
	for c in components: 
		if c.get_class() == type_name:
			return c
	return null
