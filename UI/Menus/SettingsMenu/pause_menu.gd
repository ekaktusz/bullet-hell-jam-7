extends Control

var bus_idx = AudioServer.get_bus_index("Master")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_check_button_toggled(toggled_on: bool) -> void:
	CommonGlobals.controller_support_on = toggled_on


func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	AudioServer.set_bus_mute(bus_idx, value < 0.01)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("AS?DAS?DAS?D?A")
		GameEvents.pause()
