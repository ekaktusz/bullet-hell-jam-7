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


func _ready() -> void:
	update_bullet_label()


func _process(delta: float) -> void:
	if Progression.has_skill("rapid_fire"):
		shoot_timer -= delta
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and shoot_timer <= 0.0:
			spawn_bullet()
			shoot_timer = shoot_cooldown


func _input(event: InputEvent) -> void:
	if Progression.has_skill("rapid_fire"):
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
	if Progression.has_skill("split_shot"):
		directions = [
			direction.rotated(-split_shot_angle),
			direction,
			direction.rotated(split_shot_angle)
		]

	var modifiers = []
	if Progression.has_skill("heavy_bullets"):
		modifiers.append("heavy")
	if Progression.has_skill("fast_bullets"):
		modifiers.append("fast")

	for shot_direction in directions.slice(0, max_bullet_count - bullets.size()):
		spawn_single_bullet(spawn_pos, shot_direction, modifiers)
	update_bullet_label()


func spawn_single_bullet(spawn_pos: Vector2, direction: Vector2, modifiers: Array) -> void:
	var bullet = BULLET.instantiate()
	bullet.global_position = spawn_pos
	bullet.velocity = direction * bullet.bullet_speed
	bullets.append(bullet)
	bullet.remove_bullet.connect(_on_bullet_remove)
	bullet.apply_impact.connect(_on_apply_impact)
	bullet.spawn_bad_though.connect(_on_spawn_bad_thought)
	add_child(bullet)
	bullet.setup_bullet(modifiers)


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
