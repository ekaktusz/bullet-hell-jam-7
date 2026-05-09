extends CPUParticles2D


func play() -> void:
	emitting = true
	await get_tree().create_timer(lifetime).timeout
	queue_free()
