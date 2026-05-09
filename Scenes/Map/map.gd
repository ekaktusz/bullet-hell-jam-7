extends Node2D

@onready var line_2d: Line2D = $Line2D
@onready var brain: CharacterBody2D = $Brain
@onready var bullet_manager: BulletManager = $Bullets
@onready var time_label: Label = $CanvasLayer/TimeLabel
@onready var current_money_label: Label = $CanvasLayer/CurrencyLabel
@onready var hp_label: Label = $CanvasLayer/HpLabel
@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var skill_tree: Control = $SkillTree
@onready var bullets: BulletManager = $Bullets
@onready var thoughts: Node2D = $Thoughts

const THOUGHT = preload("uid://bh5ungrieylu3")
const MIN_BASE_RADIUS := 100.0

var noise = FastNoiseLite.new()
var damping = 0.97
var spike_size = 250
var points = []
var base_radius = SkillDatabase.wall_size
var segments := 512
var velocities = []
var run_time := 0.0
var brain_outside_time := 0.0

const OUTSIDE_CONFIRM_TIME := 0.08
const OUTSIDE_TOLERANCE := 3.0


func _ready() -> void:
	bullet_manager.bullet_impact.connect(_on_apply_impact)
	bullet_manager.bad_thought_requested.connect(spawn_bad_thought)
	SkillDatabase.refresh_tree.connect(_on_update_tree)
	GameEvents.hit_player_emitter.connect(_on_update_hp_label)
	GameEvents.reset_hp_emitter.connect(_on_update_hp_label)
	skill_tree.restart_run.connect(_on_restart)
	update_current_money_label()
	noise.frequency = 2
	global_position = get_viewport_rect().size / 2.0
	generate_blob(0)


func _process(delta: float) -> void:
	run_time += delta
	time_label.text = "TIME x reward multiplier: " + str(int(run_time * SkillDatabase.reward_multiplier))
	base_radius -= delta * 20.0
	base_radius = max(base_radius, MIN_BASE_RADIUS)
	update_blob(delta)


func generate_blob(time: float) -> void:
	points.clear()
	velocities.clear()

	var radius_x = base_radius * 1.6  # stretch horizontally
	var radius_y = base_radius * 1  # slightly squash vertically

	for i in range(segments):
		var angle = TAU * i / segments
		var n = noise.get_noise_2d(cos(angle) + time, sin(angle) + time)

		var radius = base_radius + n * spike_size

		var dir = Vector2(cos(angle), sin(angle))

		# apply ellipse scaling
		var point = Vector2(
			dir.x * radius * radius_x / base_radius,
			dir.y * radius * radius_y / base_radius
		) * radius / base_radius

		points.append(point)
		velocities.append(Vector2.ZERO)

	line_2d.points = points
	polygon_2d.polygon = points


func update_blob(delta: float) -> void:
	
	check_outside()
	points.sort_custom(func(a, b):
		return atan2(a.y, a.x) < atan2(b.y, b.x)
	)
	for i in range(points.size()):
		var point = points[i]
		var velocity = velocities[i]
		var inward = -point.normalized() * SkillDatabase.wall_speed

		var prev = points[(i - 1 + points.size()) % points.size()]
		var next = points[(i + 1) % points.size()]
		var center = (prev + next) * 0.5
		velocity += (center - point) * 8.0 * delta
		velocity *= damping
		point += (inward + velocity) * delta
		points[i] = point
		velocities[i] = velocity
	line_2d.points = points
	polygon_2d.polygon = points
	


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


func get_distance_to_boundary(point: Vector2) -> float:
	var closest_dist := INF
	for i in range(points.size()):
		var a = points[i]
		var b = points[(i + 1) % points.size()]
		var closest = Geometry2D.get_closest_point_to_segment(point, a, b)
		closest_dist = min(closest_dist, point.distance_to(closest))
	return closest_dist


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
		var collision_shape: CollisionShape2D = brain.get_node("CollisionShape2D")
		var shape = collision_shape.shape

		if shape is CircleShape2D:
			var radius = shape.radius * max(absf(collision_shape.global_scale.x), absf(collision_shape.global_scale.y))
			var center = to_local(collision_shape.global_position)
			var center_is_inside = Geometry2D.is_point_in_polygon(center, points)
			var distance_to_boundary = get_distance_to_boundary(center)
			var overlaps_boundary = center_is_inside and distance_to_boundary < radius - OUTSIDE_TOLERANCE

			if !center_is_inside or overlaps_boundary:
				brain_outside_time += get_process_delta_time()
				if brain_outside_time >= OUTSIDE_CONFIRM_TIME:
					print("END RUN")
					end_run()
					brain.hide()
			else:
				brain_outside_time = 0.0
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
	thoughts.add_child(thought)


func end_run() -> void:
	bullet_manager.bullets = []
	for child in bullets.get_children():
		child.queue_free()
	for child in thoughts.get_children():
		child.queue_free()
	var earned = int(run_time * SkillDatabase.reward_multiplier)

	SkillDatabase.current_money += earned
	update_current_money_label()

	print("EARNED:", earned)
	SkillDatabase.refresh_tree.emit()
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = true
	skill_tree.show()


func _on_update_tree():
	skill_tree.refresh_tree()
	update_current_money_label()

func update_current_money_label() -> void:
	current_money_label.text = "current_money: " + str(SkillDatabase.current_money)

func _on_restart():
	run_time = 0.0
	brain_outside_time = 0.0
	base_radius = SkillDatabase.wall_size
	generate_blob(0)
	brain.position = Vector2.ZERO
	brain.show()
	time_label.text = "TIME: 0"
	skill_tree.hide()
	GameEvents.reset_hp()
	get_tree().paused = false
	
func _on_update_hp_label():
	if GameEvents.current_hp < 1:
		end_run()
	hp_label.text = "HP: " + str(GameEvents.current_hp)
