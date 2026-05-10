extends CharacterBody2D

@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2d
signal remove_bullet
signal apply_impact
signal spawn_bad_though

var type

#ha kell később változatosság akkor egy setterben ezeket majd lehet változtatgatni
var impact_force = 300
var impact_radius = 100
var bullet_speed = 500
var max_bounce = 3
var double_hit = 2
var can_bounce := true

#ez kell a hitbox miatt különben az area túl gyorsan leszedi 
var bounce_cooldown := 0.1
var time_to_remove_bullet = 0.05

# bounce tweakek:
var min_dot = 0.2
var correction_strength = 0.4 

var has_bounced = false

func _physics_process(delta: float) -> void:
	move_and_slide()

func _ready() -> void:
	scale = Vector2(SkillDatabase.bullet_size,SkillDatabase.bullet_size)
	print(type)
	match type:
		"fast":
			fast_bullet_chance()
		"ghost":
			ghost_bullet_chance()
		"heavy":
			heavy_bullet_chance()
		"split_shot":
			pass	
			
func ghost_bullet_chance():
	self.add_to_group("ghost")
	sprite_2d.play("bullet_blue")
	sprite_2d.modulate = Color("0000007f")
			
func fast_bullet_chance():
	print("fast")
	impact_force = impact_force / 2
	impact_radius = impact_radius
	velocity = velocity * 2
	max_bounce = 10
	sprite_2d.play("bullet_green")
	#sprite_2d.modulate = Color("F1FCD7")
	
func heavy_bullet_chance():
	print("heacy")
	impact_force *= double_hit * 2
	impact_radius *= 1.5
	velocity = velocity / 2
	sprite_2d.play("bullet_red")
	#sprite_2d.modulate = Color("D0AAC2")
	

func bounce_bullet(normal: Vector2):
	max_bounce -= 1
	has_bounced = true
	if max_bounce <= 0:
		trigger_bullet_remove()
		return
	
	var v = velocity.normalized()
	var dot = v.dot(normal)

	if abs(dot) < min_dot:
		var tangent = Vector2(-normal.y, normal.x)
		var sign = signf(v.dot(tangent))
		normal = (normal + tangent * sign * (min_dot - abs(dot)) * correction_strength).normalized()
	velocity = velocity.bounce(normal) * 0.9

func try_bounce(normal: Vector2):
	if !can_bounce:
		return

	can_bounce = false
	bounce_bullet(normal)
	apply_impact.emit(self)
	start_cooldown()

func trigger_bullet_remove():
	self.hide()
	remove_bullet.emit(get_instance_id())
	remove_bullet_after_timer()

func remove_bullet_after_timer():
	await get_tree().create_timer(time_to_remove_bullet).timeout
	queue_free()

func start_cooldown():
	await get_tree().create_timer(bounce_cooldown).timeout
	can_bounce = true

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and has_bounced && type != "ghost":
		GameEvents.hit_player()
		spawn_bad_though.emit()
		trigger_bullet_remove()
