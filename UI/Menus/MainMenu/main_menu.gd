extends Control


func _on_exit_button_pressed() -> void:
	await SoundManager.play_click_sound().finished
	get_tree().quit()


func _on_start_button_pressed() -> void:
	await SoundManager.play_click_sound().finished
	get_tree().change_scene_to_file("res://game_loop.tscn")
