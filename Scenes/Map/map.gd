extends Node2D

@onready var line_2d: Line2D = $Line2D
@onready var brain: CharacterBody2D = $Brain
@onready var bullet_manager: BulletManager = $Bullets
@onready var time_label: Label = $CanvasLayer/TimeLabel
@onready var currency_label: Label = $CanvasLayer/CurrencyLabel

const THOUGHT = preload("uid://bh5ungrieylu3")

var map_speed = 25
var noise = FastNoiseLite.new()
var damping = 0.97
var spike_size = 250
var points = []
var base_radius = 600
var segments := 512
var velocities = []
var run_time := 0.0


func _ready() -> void:
	Progression.currency_changed.connect(_on_currency_changed)
	bullet_manager.bullet_impact.connect(_on_apply_impact)
	bullet_manager.bad_thought_requested.connect(spawn_bad_thought)
	update_currency_label()
	noise.frequency = 2
	global_position = get_viewport_rect().size / 2.0
	generate_blob(0)


func _process(delta: float) -> void:
	run_time += delta
	time_label.text = "TIME: " + str(int(run_time))
	currency_label.text = "Currency: " + str(Progression.currency)
	base_radius -= delta * 20.0
	base_radius = max(base_radius, 100.0)
	update_blob(delta)


func generate_blob(time: float) -> void:
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


func update_blob(delta: float) -> void:
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


func check_outside() -> void:
	check_bullets_outside()
	check_brain_outside()


func check_bullets_outside() -> void:
	for bullet in bullet_manager.get_bullets():
		var local = to_local(bullet.global_position)
		if !Geometry2D.is_point_in_polygon(local, points):
			var normal = get_closest_normal(local)
			bullet.try_bounce(normal)


func check_brain_outside() -> void:
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
				pos + Vector2(radius, radius).normalized() * radius,
				pos + Vector2(-radius, radius).normalized() * radius,
				pos + Vector2(radius, -radius).normalized() * radius,
				pos + Vector2(-radius, -radius).normalized() * radius,
			]

			for p in test_points:
				var local_p = to_local(p)

				if !Geometry2D.is_point_in_polygon(local_p, points):
					print("END RUN")
					end_run()
					brain.hide()
					break
				else:
					brain.show()


func _on_apply_impact(bullet) -> void:
	var local_hit = to_local(bullet.global_position)
	spawn_thought(local_hit, true)
	for i in range(points.size()):
		var point = points[i]
		var dist = point.distance_to(local_hit)
		if dist < bullet.impact_radius:
			var influence = 1.0 - (dist / bullet.impact_radius)
			var outward = point.normalized()
			velocities[i] += outward * bullet.impact_force * influence


func spawn_bad_thought(position: Vector2) -> void:
	spawn_thought(position, false)


func spawn_thought(position: Vector2, is_good: bool) -> void:
	var thought = THOUGHT.instantiate()
	thought.is_good = is_good
	thought.position = position
	get_tree().current_scene.add_child(thought)


func end_run() -> void:
	var earned = int(run_time)
	Progression.currency += earned
	print("EARNED:", earned)
	get_tree().paused = true
	var skill_tree = preload("res://Scenes/SkillTree/skill_tree.tscn").instantiate()
	get_tree().current_scene.add_child(skill_tree)


func _on_currency_changed(value) -> void:
	currency_label.text = "Currency: " + str(value)


func update_currency_label() -> void:
	currency_label.text = "Currency: " + str(Progression.currency)
