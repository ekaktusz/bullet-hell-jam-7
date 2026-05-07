extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
signal remove_bullet
signal apply_impact

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

# bounce tweakek:
var min_dot = 0.2
var correction_strength = 0.4 

var has_bounced = false

func setup_bullet(modifiers: Array):
	for modifier in modifiers:
		match modifier:
			"heavy":
				impact_force *= double_hit * 2
				impact_radius *= 1.5
				velocity *= 0.5
				sprite_2d.modulate = Color.FIREBRICK
			"fast":
				impact_force *= 0.5
				velocity *= 2.0
				max_bounce = 10
				sprite_2d.modulate = Color.YELLOW

func _physics_process(delta: float) -> void:
	move_and_slide()

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
	if area.is_in_group("player") and has_bounced:
		print("HUT DETECTED")
		trigger_bullet_remove()
