extends Node2D

#@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var polygon_2d: Line2D = $Line2D
@onready var brain: CharacterBody2D = $Brain
@onready var bullets_container: Node2D = $Bullets
const BULLET = preload("uid://cycafl512rjsx")

#map 
var map_speed = 20
var noise = FastNoiseLite.new()
var wobble = 1000
var damping = 0.97
var spike_size = 250
var points = []
var base_radius = 600
var segments := 512
var velocities = []
var bullets = []

var shoot_cooldown = 0.1
var can_shoot = true

func _ready():
	noise.frequency = 2
	global_position = get_viewport_rect().size / 2.0
	generate_blob(0)
	
func _process(delta):
	base_radius -= delta * 20.0
	base_radius = max(base_radius, 100.0)
	update_blob(delta)

func generate_blob(time: float):
	points.clear()
	for i in range(segments):
		var angle = TAU * i / segments
		var n = noise.get_noise_2d(cos(angle) + time, sin(angle) + time)
		var radius = base_radius + n * spike_size
		var point = Vector2(cos(angle), sin(angle)) * radius
		points.append(point)
		velocities.append(Vector2.ZERO)
	polygon_2d.points = points

			
func update_blob(delta: float):
	check_outside()
	points.sort_custom(func(a, b):
		return atan2(a.y, a.x) < atan2(b.y, b.x)
	)
	for i in range(points.size()):
		var point = points[i]
		var velocity = velocities[i]
		var inward = -point.normalized() * map_speed
		var prev = points[(i - 1 + points.size()) % points.size()]
		var next = points[(i + 1) % points.size()]
		var center = (prev + next) * 0.5
		velocity += (center - point) * 8.0 * delta 
		velocity *= damping
		point += (inward + velocity) * delta
		points[i] = point
		velocities[i] = velocity
	polygon_2d.points = points
	

func check_outside():
	for bullet in bullets:
		var pos = bullet.global_position
		var extents = Vector2(bullet.body_size_x, bullet.body_size_y)
		var test_points = [
			pos,
			pos + Vector2(extents.x, 0),
			pos + Vector2(-extents.x, 0),
			pos + Vector2(0, extents.y),
			pos + Vector2(0, -extents.y),
			pos + Vector2(extents.x, extents.y),
			pos + Vector2(-extents.x, extents.y),
			pos + Vector2(extents.x, -extents.y),
			pos + Vector2(-extents.x, -extents.y),
		]
		for p in test_points:
			var local = to_local(p)
			if !Geometry2D.is_point_in_polygon(local, points):
				bullet.try_bounce()
				
				
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if can_shoot:
			can_shoot = false
			shoot_cooldown_timer()
			spawn_bullet()


func spawn_bullet():
	var bullet = BULLET.instantiate()
	var mouse_pos = get_global_mouse_position()
	var spawn_pos = brain.position
	var direction = (mouse_pos - to_global(spawn_pos)).normalized()
	bullet.global_position = spawn_pos
	bullet.velocity = direction * bullet.bullet_speed
	bullets.append(bullet)
	bullet.remove_bullet.connect(_on_bullet_remove)
	bullet.apply_impact.connect(_on_apply_impact)
	bullets_container.add_child(bullet)

func _on_bullet_remove(id):
	for bullet in bullets:
		if bullet.get_instance_id() == id:
			bullets.erase(bullet)
			return

func _on_apply_impact(bullet):
	var local_hit = to_local(bullet.global_position)
	for i in range(points.size()):
		var point = points[i]
		var dist = point.distance_to(local_hit)
		if dist < bullet.impact_radius:
			var influence = 1.0 - (dist / bullet.impact_radius)
			var outward = (point - Vector2.ZERO).normalized()
			velocities[i] += outward * bullet.impact_force * influence
			
func shoot_cooldown_timer():
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
