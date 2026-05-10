extends CharacterBody2D

const STOP_SPEED = 2500.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	SkillDatabase.player_size_skill_emitter.connect(_on_player_size_level_up)
	GameEvents.hit_player_emitter.connect(_on_hit_player)
	GameEvents.shoot.connect(_on_shoot)
	
func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction != Vector2.ZERO:
		velocity = direction * SkillDatabase.player_speed
	else:
		#velocity = Vector2.ZERO
		velocity = velocity.move_toward(Vector2.ZERO, STOP_SPEED * delta)

	rotation = (get_global_mouse_position() - global_position).angle() + PI / 2
	move_and_slide()


func _on_player_size_level_up():
	scale = Vector2(SkillDatabase.player_size, SkillDatabase.player_size)


func _on_shoot():
	animated_sprite_2d.play("shoot")


func _on_hit_player():
	SoundManager.play_sound_by_id(SoundManager.Sound.BRAIN_DMG)
	animated_sprite_2d.play("hit")
