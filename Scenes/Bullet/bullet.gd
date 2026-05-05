extends CharacterBody2D

signal remove_bullet
signal apply_impact
var max_bounce = 3
var can_bounce := true
var bounce_cooldown := 0.1
var time_to_remove_bullet = 0.05

func _physics_process(delta: float) -> void:
	move_and_slide()

func bounce_bullet():
	print("bounce")
	max_bounce = max_bounce -1
	print(max_bounce)
	if (max_bounce == 0):
		remove_bullet.emit(get_instance_id())
		remove_bullet_after_timer()
	velocity = velocity * -1

func try_bounce(pos):
	if !can_bounce:
		return

	can_bounce = false
	bounce_bullet()
	apply_impact.emit(pos)
	start_cooldown()

func remove_bullet_after_timer():
	await get_tree().create_timer(time_to_remove_bullet).timeout
	queue_free()

func start_cooldown():
	await get_tree().create_timer(bounce_cooldown).timeout
	can_bounce = true
