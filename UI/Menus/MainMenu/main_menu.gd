extends Control

const MAP_SCENE = preload("res://Scenes/Map/Map.tscn")

func _ready() -> void:
	MusicPlayer.play_chill_music()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(MAP_SCENE)
