extends Area2D

@onready var line_2d: Line2D = $Line2D
@onready var collision_poly: CollisionPolygon2D = $CollisionPolygon2D

# Configuración de la onda
@export var speed: float = 400.0
@export var growth_rate: float = 3.0 # Cuánto crece la escala por segundo
@export var lifetime: float = 0.8 # Dura menos de 1 seg como pediste
@export var arc_angle: float = 60.0 # Qué tan "abierto" es el arco en grados
@export var radius: float = 20.0 # Tamaño inicial
@export var segments: int = 15 # Calidad de la curva

var direction: Vector2 = Vector2.RIGHT
var timer: float = 0.0

func _ready():
	rotation = direction.angle()
	create_wave_shape()
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta
	scale += Vector2(growth_rate, growth_rate) * delta
	modulate.a = 1.0 - (timer / lifetime)
	timer += delta
	if timer >= lifetime:
		queue_free()

func create_wave_shape():
	var points_arc = []
	var angle_rad = deg_to_rad(arc_angle)
	var start_angle = -angle_rad / 2
	
	for i in range(segments + 1):
		var theta = start_angle + (i * angle_rad / segments)
		var x = cos(theta) * radius
		var y = sin(theta) * radius
		points_arc.append(Vector2(x, y))
	
	line_2d.points = points_arc
	var poly_points = points_arc.duplicate()
	
	var inner_points = []
	for i in range(segments, -1, -1):
		var theta = start_angle + (i * angle_rad / segments)
		var x = cos(theta) * (radius - 5) 
		var y = sin(theta) * (radius - 5)
		inner_points.append(Vector2(x, y))
		
	poly_points.append_array(inner_points)

	collision_poly.polygon = poly_points

func _on_body_entered(body: Node2D):
	if body.is_in_group("moth") or body is FlyingEnemy2:
		if body.has_method("die"):
			body.die()
