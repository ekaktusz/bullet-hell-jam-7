extends Control

const MAP_SCENE = preload("res://Scenes/Map/Map.tscn")

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(MAP_SCENE)
