extends Node2D

class_name BulletManager

signal bullet_impact(bullet)
signal bad_thought_requested(position: Vector2)

const BULLET = preload("uid://cycafl512rjsx")

@onready var brain: CharacterBody2D = $"../Brain"
@onready var bullets_label: Label = $"../CanvasLayer/BulletsLabel"

var bullets: Array = []
var shoot_cooldown := 0.1
var shoot_timer := 0.0
var can_shoot := true
var max_bullet_count := 100
var split_shot_angle := deg_to_rad(15.0)
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	update_bullet_label()


func _process(delta: float) -> void:
	if SkillDatabase.rapid_fire_skill.is_unlocked():
		shoot_timer -= delta
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and shoot_timer <= 0.0:
			spawn_bullet()
			shoot_timer = shoot_cooldown


func _input(event: InputEvent) -> void:
	if SkillDatabase.rapid_fire_skill.is_unlocked():
		return
	if event is InputEventMouseButton and event.pressed and can_shoot:
		can_shoot = false
		shoot_cooldown_timer()
		spawn_bullet()


func get_bullets() -> Array:
	return bullets


func spawn_bullet() -> void:
	if !brain:
		return
	if bullets.size() >= max_bullet_count:
		return

	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - to_global(brain.position)).normalized()
	var spawn_pos = brain.position + direction * brain.get_node("CollisionShape2D").shape.radius
	var directions = [direction]
	if SkillDatabase.split_shot_skill.is_unlocked():
		directions = [
			direction,
			direction.rotated(-split_shot_angle),
			direction.rotated(split_shot_angle)
		]

	var modifiers = []
	if SkillDatabase.heavy_bullets_skill.is_unlocked():
		modifiers.append("heavy")
	if SkillDatabase.fast_bullets_skill.is_unlocked():
		modifiers.append("fast")

	var bullet_rng = rng.randf()

	for shot_direction in directions.slice(0, max_bullet_count - bullets.size()):
		spawn_single_bullet(spawn_pos, shot_direction, bullet_rng)
	update_bullet_label()


func spawn_single_bullet(spawn_pos: Vector2, direction: Vector2, bullet_rng: float) -> void:
	var bullet = BULLET.instantiate()
	bullet.global_position = spawn_pos
	bullet.velocity = direction * bullet.bullet_speed
	bullet.bullet_rng = bullet_rng
	bullets.append(bullet)
	bullet.remove_bullet.connect(_on_bullet_remove)
	bullet.apply_impact.connect(_on_apply_impact)
	bullet.spawn_bad_though.connect(_on_spawn_bad_thought)
	add_child(bullet)


func update_bullet_label() -> void:
	bullets_label.text = str(bullets.size()) + " / " + str(max_bullet_count)


func _on_bullet_remove(id: int) -> void:
	for bullet in bullets:
		if bullet.get_instance_id() == id:
			bullets.erase(bullet)
			update_bullet_label()
			return


func _on_apply_impact(bullet) -> void:
	bullet_impact.emit(bullet)


func _on_spawn_bad_thought() -> void:
	bad_thought_requested.emit(brain.position)


func shoot_cooldown_timer() -> void:
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
