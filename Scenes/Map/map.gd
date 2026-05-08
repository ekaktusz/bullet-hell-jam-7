extends Node2D

@onready var line_2d: Line2D = $Line2D
@onready var brain: CharacterBody2D = $Brain
@onready var bullets_container: Node2D = $Bullets
@onready var label: Label = $CanvasLayer/BulletsLabel
@onready var time_label: Label= $CanvasLayer/TimeLabel
@onready var currency_label: Label = $CanvasLayer/CurrencyLabel
const BULLET = preload("uid://cycafl512rjsx")

#map 
var map_speed = 25
var noise = FastNoiseLite.new()
var damping = 0.97
var spike_size = 250
var points = []
var base_radius = 600
var segments := 512
var velocities = []
var bullets = []

#var rapid_fire_unlocked = false
var shoot_cooldown = 0.1
var shoot_timer := 0.0
var can_shoot = true

var max_bullet_count = 10
var run_time := 0.0

func _ready():
	noise.frequency = 2
	global_position = get_viewport_rect().size / 2.0
	generate_blob(0)
	
func _process(delta):
	run_time += delta
	time_label.text = "TIME: " + str(int(run_time))
	currency_label.text = "Currency: " + str(Progression.currency)
	base_radius -= delta * 20.0
	base_radius = max(base_radius, 100.0)
	update_blob(delta)
	if Progression.has_skill("rapid_fire"):
		shoot_timer -= delta
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if shoot_timer <= 0.0:
				spawn_bullet()
				shoot_timer = shoot_cooldown

func _input(event):
	if not Progression.has_skill("rapid_fire"):
		if event is InputEventMouseButton and event.pressed:
			if can_shoot:
				can_shoot = false
				shoot_cooldown_timer()
				spawn_bullet()

func generate_blob(time: float):
	points.clear()
	velocities.clear()
	for i in range(segments):
		var angle = TAU * i / segments
		var n = noise.get_noise_2d(cos(angle) + time, sin(angle) + time)
		var radius = base_radius + n * spike_size
		var point = Vector2(cos(angle), sin(angle)) * radius
		points.append(point)
		velocities.append(Vector2.ZERO)
	line_2d.points = points

			
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
	line_2d.points = points


func get_closest_normal(point: Vector2) -> Vector2:
	var closest_dist = INF
	var best_normal = Vector2.ZERO
	for i in range(points.size()):
		var a = points[i]
		var b = points[(i + 1) % points.size()]
		var closest = Geometry2D.get_closest_point_to_segment(point, a, b)
		var dist = point.distance_to(closest)
		if dist < closest_dist:
			closest_dist = dist
			var edge = (b - a).normalized()
			var normal = Vector2(-edge.y, edge.x)
			if normal.dot(point) < 0:
				normal = -normal
			best_normal = normal
	return best_normal

func check_outside():
	check_bullets_outside()
	check_brain_outside()

func check_bullets_outside():
	for bullet in bullets:
		var local = to_local(bullet.global_position)
		if !Geometry2D.is_point_in_polygon(local, points):
			var normal = get_closest_normal(local)
			bullet.try_bounce(normal)

func check_brain_outside():
	if brain:
		var shape = brain.get_node("CollisionShape2D").shape

		if shape is CircleShape2D:
			var radius = shape.radius
			var pos = brain.global_position

			var test_points = [
				pos,
				pos + Vector2(radius, 0),
				pos + Vector2(-radius, 0),
				pos + Vector2(0, radius),
				pos + Vector2(0, -radius),

				# diagonals
				pos + Vector2(radius, radius).normalized() * radius,
				pos + Vector2(-radius, radius).normalized() * radius,
				pos + Vector2(radius, -radius).normalized() * radius,
				pos + Vector2(-radius, -radius).normalized() * radius,
			]

			for p in test_points:
				var local_p = to_local(p)

				if !Geometry2D.is_point_in_polygon(local_p, points):
					end_run()
					##trigger end-run mechaning and the rest is not needed
					brain.hide()
					break
				else: brain.show()

func spawn_bullet():
	if brain && bullets.size() <= max_bullet_count:
		update_bullet_label()
		var bullet = BULLET.instantiate()
		var mouse_pos = get_global_mouse_position()
		var spawn_pos = brain.position
		var direction = (mouse_pos - to_global(spawn_pos)).normalized()
		bullet.global_position = spawn_pos
		bullet.velocity = direction * bullet.bullet_speed
		var modifiers = []
		if Progression.has_skill("heavy_bullets"):
			modifiers.append("heavy")
		if Progression.has_skill("fast_bullets"):
			modifiers.append("fast")
		bullets.append(bullet)
		bullet.remove_bullet.connect(_on_bullet_remove)
		bullet.apply_impact.connect(_on_apply_impact)
		bullets_container.add_child(bullet)
		bullet.setup_bullet(modifiers)

func update_bullet_label():
	label.text = str(bullets.size()) + " / " + str(max_bullet_count)

func _on_bullet_remove(id):
	for bullet in bullets:
		if bullet.get_instance_id() == id:
			bullets.erase(bullet)
			update_bullet_label()
			return

func _on_apply_impact(bullet):
	var local_hit = to_local(bullet.global_position)
	for i in range(points.size()):
		var point = points[i]
		var dist = point.distance_to(local_hit)
		if dist < bullet.impact_radius:
			var influence = 1.0 - (dist / bullet.impact_radius)
			var outward = point.normalized()
			velocities[i] += outward * bullet.impact_force * influence

func shoot_cooldown_timer():
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
	
func end_run():
	var earned = int(run_time)
	Progression.currency += earned
	print("EARNED:", earned)
	get_tree().paused = true
	var skill_tree = preload("res://Scenes/SkillTree/skill_tree.tscn").instantiate()
	get_tree().current_scene.add_child(skill_tree)
