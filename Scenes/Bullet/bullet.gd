extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
signal remove_bullet
signal apply_impact

#ez átmeneti majd a skilltree megmondja mennyi esély lesz faszább bulletre
var rng = RandomNumberGenerator.new()

#ha kell később változatosság akkor egy setterben ezeket majd lehet változtatgatni
var body_size_x = 16
var body_size_y = 16
var impact_force = 300
var impact_radius = 100
var bullet_speed = 500
var max_bounce = 3
var can_bounce := true
var double_hit = 2

#ez kell a hitbox miatt különben az area túl gyorsan leszedi 
var bounce_cooldown := 0.1
var time_to_remove_bullet = 0.05

func _ready() -> void:
	var number = rng.randf()
	if number < 0.1:
		big_bullet_chance()
	elif number > 0.9:
		fast_bullet_chance()
	
	
func fast_bullet_chance():
	impact_force = impact_force / 2
	impact_radius = impact_radius
	velocity = velocity * 2
	max_bounce = 10
	sprite_2d.modulate = Color.YELLOW
	
func big_bullet_chance():
	impact_force *= double_hit * 2
	impact_radius *= 1.5
	velocity = velocity / 2
	sprite_2d.modulate = Color.FIREBRICK

func _physics_process(delta: float) -> void:
	move_and_slide()

func bounce_bullet():
	max_bounce = max_bounce -1
	if (max_bounce == 0):
		remove_bullet.emit(get_instance_id())
		remove_bullet_after_timer()
	velocity = velocity * -1

func try_bounce():
	if !can_bounce:
		return

	can_bounce = false
	bounce_bullet()
	apply_impact.emit(self)
	start_cooldown()

func remove_bullet_after_timer():
	await get_tree().create_timer(time_to_remove_bullet).timeout
	queue_free()

func start_cooldown():
	await get_tree().create_timer(bounce_cooldown).timeout
	can_bounce = true
