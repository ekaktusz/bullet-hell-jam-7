extends Control

var bus_idx = AudioServer.get_bus_index("Master")
const MAP_SCENE = preload("res://Scenes/Map/Map.tscn")

@onready var start_button: Button = $StartButton
@onready var check_button: CheckButton = $CheckButton


func _ready() -> void:
	var cursor = load("res://assets/cursor.png").get_image()
	cursor.resize(32, 32)
	var tex = ImageTexture.create_from_image(cursor)
	Input.set_custom_mouse_cursor(tex)
	MusicPlayer.play_chill_music()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(MAP_SCENE)


func _on_check_button_toggled(toggled_on: bool) -> void:
	CommonGlobals.controller_support_on = toggled_on


func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(bus_idx, value < 0.01)
