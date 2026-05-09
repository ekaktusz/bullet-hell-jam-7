extends CharacterBody2D

const SPEED = 300.0
const STOP_SPEED = 2500.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else:
		#velocity = Vector2.ZERO
		velocity = velocity.move_toward(Vector2.ZERO, STOP_SPEED * delta)

	rotation = (get_global_mouse_position() - global_position).angle() + PI / 2
	move_and_slide()
