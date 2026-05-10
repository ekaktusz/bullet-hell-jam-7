extends Control

const MAP_SCENE = preload("res://Scenes/Map/Map.tscn")

@onready var start_button: Button = $StartButton

@onready var check_button: CheckButton = $CheckButton


func _ready() -> void:
	#start_button.grab_focus()
	pass

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(MAP_SCENE)


func _on_check_button_toggled(toggled_on: bool) -> void:
	CommonGlobals.controller_support_on = toggled_on
