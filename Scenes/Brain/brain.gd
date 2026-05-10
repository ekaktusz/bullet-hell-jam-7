extends CharacterBody2D

const STOP_SPEED = 2500.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var last_mouse_position := Vector2.ZERO

func _ready() -> void:
	SkillDatabase.player_size_skill_emitter.connect(_on_player_size_level_up)
	GameEvents.hit_player_emitter.connect(_on_hit_player)
	GameEvents.shoot.connect(_on_shoot)
	last_mouse_position = get_global_mouse_position()

const AIM_DEADZONE = 0.3

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction != Vector2.ZERO:
		velocity = direction * SkillDatabase.player_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, STOP_SPEED * delta)

	var current_mouse_position := get_global_mouse_position()
	var aim_vector := Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	if aim_vector.length() > AIM_DEADZONE:
		rotation = aim_vector.angle() + PI / 2
		last_mouse_position = current_mouse_position
	elif current_mouse_position != last_mouse_position:
		rotation = (current_mouse_position - global_position).angle() + PI / 2
		last_mouse_position = current_mouse_position
	move_and_slide()


func _on_player_size_level_up():
	scale = Vector2(SkillDatabase.player_size, SkillDatabase.player_size)


func _on_shoot():
	animated_sprite_2d.play("shoot")


func _on_hit_player():
	animated_sprite_2d.play("hit")
