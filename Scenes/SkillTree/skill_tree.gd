extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _on_rapid_fire_pressed():
	Progression.unlock_skill("rapid_fire")
	print("rapid_fire unlocked")

func _on_heavy_pressed():
	Progression.unlock_skill("heavy_bullets")
	print("heavy_bullets unlocked")

func _on_fast_pressed():
	Progression.unlock_skill("fast_bullets")
	print("fast_bullets unlocked")

func _on_restart_pressed():
	get_tree().paused = false
	queue_free()
	get_tree().reload_current_scene()
	print("RESTART PRESSED")
