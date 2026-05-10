extends Control

func _process(delta: float) -> void:
	print("fing")

func _on_start_button_pressed() -> void:
	#await SoundManager.play_click_sound().finished
	print("segg")
	get_tree().change_scene_to_file("res://Scenes/Map/Map.tscn")
