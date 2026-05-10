extends Node2D


func _on_texture_button_pressed() -> void:
	GameEvents.keep_playing.emit()
