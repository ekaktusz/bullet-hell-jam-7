extends Node2D

class_name BulletManager

signal bullet_impact(bullet)
signal bad_thought_requested(position: Vector2)

const BULLET = preload("uid://cycafl512rjsx")

@onready var brain: CharacterBody2D = $"../Brain"

var bullets: Array = []
var shoot_cooldown := 0.15
var shoot_timer := 0.0
var can_shoot := true
var trigger_pressed := false

var split_shot_angle := deg_to_rad(15.0)
var rng = RandomNumberGenerator.new()


func _process(delta: float) -> void:
	if SkillDatabase.rapid_fire_skill.is_unlocked():
		shoot_timer -= delta
		var shooting := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT) > 0.5
		if shooting and shoot_timer <= 0.0:
			spawn_bullet()
			shoot_timer = shoot_cooldown


func _input(event: InputEvent) -> void:
	if SkillDatabase.rapid_fire_skill.is_unlocked():
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and can_shoot:
		can_shoot = false
		shoot_cooldown_timer()
		spawn_bullet()
	elif event is InputEventJoypadMotion and event.axis == JOY_AXIS_TRIGGER_RIGHT:
		var is_pressed = event.axis_value > 0.5
		if is_pressed and not trigger_pressed:
			trigger_pressed = true
			if can_shoot:
				can_shoot = false
				shoot_cooldown_timer()
				spawn_bullet()
		elif not is_pressed:
			trigger_pressed = false


func get_bullets() -> Array:
	return bullets


func spawn_bullet() -> void:
	if !brain:
		return
	if bullets.size() >= SkillDatabase.max_bullet_count:
		return

	var direction := Vector2.UP.rotated(brain.rotation)
	var spawn_pos = brain.position + direction * brain.get_node("CollisionShape2D").shape.radius
	var bullet_rng = rng.randf()
	var bullet_type = get_bullet_type(bullet_rng)
	
	var directions = [direction]

	if bullet_type == "split":
		directions = [
			direction,
			direction.rotated(-split_shot_angle),
			direction.rotated(split_shot_angle)
		]
	for shot_direction in directions.slice(0, SkillDatabase.max_bullet_count - bullets.size()):
		spawn_single_bullet(spawn_pos, shot_direction, bullet_type)


func spawn_single_bullet(spawn_pos: Vector2, direction: Vector2, bullet_type: String) -> void:
	var bullet = BULLET.instantiate()
	bullet.global_position = spawn_pos
	bullet.velocity = direction * bullet.bullet_speed
	bullet.type = bullet_type
	bullets.append(bullet)
	bullet.remove_bullet.connect(_on_bullet_remove)
	bullet.apply_impact.connect(_on_apply_impact)
	bullet.spawn_bad_though.connect(_on_spawn_bad_thought)
	add_child(bullet)
	GameEvents.shoot.emit()


func get_bullet_type(bullet_rng):
	print(bullet_rng)

	#ezek most a lvl 3 rangek, a rangeket majd csökkenthetjük amikor bekerülnek a lvl-ek
	if SkillDatabase.heavy_bullets_skill.is_unlocked() && bullet_rng < getHeavyLevelRange():
		return "heavy"
	elif SkillDatabase.fast_bullets_skill.is_unlocked() && bullet_rng > 0.15 && bullet_rng < getFastLevelRange():
		return "fast"
	elif SkillDatabase.split_shot_skill.is_unlocked() && bullet_rng > 0.3 && bullet_rng < getSplitLevelRange():
		return "split"
	elif SkillDatabase.ghost_shot_skill.is_unlocked() && bullet_rng > 0.45 && bullet_rng < getGhostLevelRange():
		return "ghost"
	else: return "normal"

func getHeavyLevelRange() -> float:
	var current_level = SkillDatabase.heavy_bullets_skill.current_level
	var value = 0.0
	match current_level:
		1: value = 0.05
		2: value = 0.10
		3: value = 0.15
	return value

func getFastLevelRange() -> float:
	var current_level = SkillDatabase.fast_bullets_skill.current_level
	var value = 0.0
	match current_level:
		1: value = 0.20
		2: value = 0.25
		3: value = 0.30
	return value

func getSplitLevelRange() -> float:
	var current_level = SkillDatabase.split_shot_skill.current_level
	var value = 0.0
	match current_level:
		1: value = 0.35
		2: value = 0.40
		3: value = 0.45
	return value

func getGhostLevelRange() -> float:
	var current_level = SkillDatabase.ghost_shot_skill.current_level
	var value = 0.0
	match current_level:
		1: value = 0.60
		2: value = 0.75
		3: value = 0.90
	return value


func _on_bullet_remove(id: int) -> void:
	for bullet in bullets:
		if bullet.get_instance_id() == id:
			bullets.erase(bullet)
			return


func _on_apply_impact(bullet) -> void:
	bullet_impact.emit(bullet)


func _on_spawn_bad_thought() -> void:
	bad_thought_requested.emit(brain.position)


func shoot_cooldown_timer() -> void:
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
