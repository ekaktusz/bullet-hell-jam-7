extends Node2D

@onready var line_2d: Line2D = $Line2D
@onready var brain: CharacterBody2D = $Brain
@onready var bullet_manager: BulletManager = $Bullets
@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var thoughts: Node2D = $Thoughts
@onready var skill_tree: Control = $UICanvasLayer/SkillMenu/SkillTree
@onready var skill_menu: Control = $UICanvasLayer/SkillMenu
@onready var camera: Camera2D = $Camera2D
@onready var rewards: Node2D = $Rewards
@onready var reward_spawn_timer: Timer = $RewardSpawnTimer

const THOUGHT = preload("uid://bh5ungrieylu3")
const BRAIN_DEATH_EFFECT = preload("res://Scenes/Brain/brain_death_effect.tscn")
const COLLECTIBLE = preload("res://Scenes/Collectible/collectible.tscn")

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
var brain_dead := false
var reward_exists := false

const OUTSIDE_CONFIRM_TIME := 0.08
const OUTSIDE_TOLERANCE := 3.0


func _ready() -> void:
	bullet_manager.bullet_impact.connect(_on_apply_impact)
	bullet_manager.bad_thought_requested.connect(spawn_bad_thought)
	GameEvents.hit_player_emitter.connect(_on_update_hp_label)
	GameEvents.reset_hp_emitter.connect(_on_update_hp_label)

	reward_spawn_timer.timeout.connect(spawn_reward)
	skill_tree.restart_run.connect(_on_restart)
	noise.frequency = 2
	global_position = get_viewport_rect().size / 2.0
	generate_blob(0)
	start_reward_timer()


func _process(delta: float) -> void:
	run_time += delta
	update_blob(delta)

	var total_dist := 0.0
	for p in points:
		total_dist += p.length()
	base_radius = total_dist / points.size()
	base_radius = max(base_radius, MIN_BASE_RADIUS)

	var viewport_half_h := get_viewport_rect().size.y / 2.0
	GlobalShaderEffect.set_vignette_radius(base_radius / viewport_half_h / 1.2)


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
				if brain_outside_time >= OUTSIDE_CONFIRM_TIME and not brain_dead:
					brain_dead = true
					print("END RUN")
					brain.hide()
					play_brain_death()
			elif not brain_dead:
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
			


func spawn_bad_thought(thought_position: Vector2) -> void:
	spawn_thought(thought_position, false)
	camera.shake(0.15, 4.0)


func play_brain_death() -> void:
	var effect = BRAIN_DEATH_EFFECT.instantiate() as CPUParticles2D
	camera.shake(effect.lifetime, 30.0)
	add_child(effect)
	effect.global_position = brain.global_position
	effect.play()
	await get_tree().create_timer(effect.lifetime).timeout
	end_run()


func spawn_thought(thought_position: Vector2, is_good: bool) -> void:
	var thought = THOUGHT.instantiate()
	thought.is_good = is_good
	thought.position = thought_position
	thoughts.add_child(thought)


func end_run() -> void:
	bullet_manager.bullets = []
	for child in bullet_manager.get_children():
		child.queue_free()
	for child in thoughts.get_children():
		child.queue_free()
	var earned = int(run_time * SkillDatabase.reward_multiplier)

	CommonGlobals.current_money += earned


	print("EARNED:", earned)
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = true
	skill_menu.show()
	skill_tree.opened()


func _on_restart():
	run_time = 0.0
	brain_outside_time = 0.0
	brain_dead = false
	base_radius = SkillDatabase.wall_size
	generate_blob(0)
	brain.position = Vector2.ZERO
	brain.show()
	skill_menu.hide()
	GameEvents.reset_hp()
	get_tree().paused = false
	for child in rewards.get_children():
		child.queue_free()
	
func _on_update_hp_label():
	if GameEvents.current_hp < 1:
		end_run()

func start_reward_timer() -> void:
	reward_spawn_timer.start(randf_range(1.0, 6.0))

func _on_reward_spawn_timer_timeout() -> void:
	spawn_reward()
	
func spawn_reward() -> void:
	if brain_dead:
		return
	if reward_exists:
		return

	reward_exists = true
	var collectible := COLLECTIBLE.instantiate() as Collectible
	collectible.position = get_random_point_in_blob()
	collectible.map_ref = self
	collectible.tree_exited.connect(_on_reward_gone)

	rewards.add_child(collectible)
	print("SPAWN POSITION: ", collectible.global_position)

func _on_reward_gone() -> void:
	reward_exists = false
	start_reward_timer()

func get_random_point_in_blob() -> Vector2:
	while true:
		var x = randf_range(-base_radius * 1.6, base_radius * 1.6)
		var y = randf_range(-base_radius, base_radius)
		var point = Vector2(x, y)
		if Geometry2D.is_point_in_polygon(point, points):
			if get_distance_to_boundary(point) > 80:
				return point
	return Vector2.ZERO
