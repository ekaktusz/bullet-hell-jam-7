extends Node2D

#@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var polygon_2d: Line2D = $Line2D
@onready var character_body_2d: CharacterBody2D = $CharacterBody2D
@onready var player: CharacterBody2D = $CharacterBody2D
@onready var bullets_container: Node2D = $Bullets
const BULLET = preload("uid://cycafl512rjsx")

#map 
var map_speed = 10
var noise = FastNoiseLite.new()
var wobble = 1000
var damping = 0.97
var points = []
var base_radius = 600
var segments := 512


var bullets = []
var velocities = []
var body_size_x = 16
var body_size_y = 16
var impact_force = 300
var impact_radius = 100
var bullet_speed = 500
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
		var radius = base_radius + n * 80.0

		var p = Vector2(cos(angle), sin(angle)) * radius
		points.append(p)
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

		# 2. NEIGHBOR SPRING (this creates wobble!)
		var prev = points[(i - 1 + points.size()) % points.size()]
		var next = points[(i + 1) % points.size()]
		var center = (prev + next) * 0.5
		velocity += (center - point) * 8.0 * delta

		# 4. damping
		velocity *= damping

		point += (inward + velocity) * delta

		points[i] = point
		velocities[i] = velocity

	polygon_2d.points = points
	

func check_outside():
	for bullet in bullets:
		var pos = bullet.global_position
		var extents = Vector2(body_size_x, body_size_y)

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
				bullet.try_bounce(pos)
				
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if can_shoot:
			can_shoot = false
			shoot_cooldown_timer()
			var bullet = BULLET.instantiate()

			var mouse_pos = get_global_mouse_position()
			var spawn_pos = player.position

			var direction = (mouse_pos - to_global(spawn_pos)).normalized()
			bullet.global_position = spawn_pos
			bullet.velocity = direction * bullet_speed
			print("spawn:" + str(spawn_pos))
			print("target: " + str(mouse_pos))
			bullets.append(bullet)
			bullet.remove_bullet.connect(_on_bullet_remove)
			bullet.apply_impact.connect(_on_apply_impact)
			bullets_container.add_child(bullet)

func _on_bullet_remove(id):
	for bullet in bullets:
		if bullet.get_instance_id() == id:
			print(id)
			bullets.erase(bullet)
			return

func _on_apply_impact(global_hit_pos: Vector2):
	var local_hit = to_local(global_hit_pos)

	for i in range(points.size()):
		var point = points[i]
		var dist = point.distance_to(local_hit)

		if dist < impact_radius:
			var influence = 1.0 - (dist / impact_radius)
			var outward = (point - Vector2.ZERO).normalized()
			velocities[i] += outward * impact_force * influence
			
func shoot_cooldown_timer():
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
