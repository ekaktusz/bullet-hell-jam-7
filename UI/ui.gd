extends CanvasLayer

var menu_stack = []

@onready var pause_menu = $PauseMenu
@onready var settings_menu = $SettingsMenu


func _ready() -> void:
	GameEvents.menu_back_pressed.connect(go_back)


func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		if menu_stack.is_empty():
			open_menu(pause_menu)
		else:
			go_back()


func open_menu(menu) -> void:
	if not menu_stack.is_empty():
		menu_stack.back().hide()

	menu_stack.push_back(menu)
	menu.show()


func go_back() -> void:
	var current_menu = menu_stack.pop_back()
	current_menu.hide()

	if menu_stack.is_empty():
		get_tree().paused = false
	else:
		menu_stack.back().show()


func _on_pause_menu_credits_menu_requested() -> void:
	# @todo: Implement credits
	pass


func _on_pause_menu_settings_menu_requested() -> void:
	open_menu(settings_menu)
