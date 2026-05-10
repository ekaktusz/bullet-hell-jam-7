extends Node

var max_hp = 5
var current_hp = 5

@warning_ignore("unused_signal")
signal menu_back_pressed
signal hit_player_emitter
signal reset_hp_emitter
signal shoot
signal pause_emitter

func hit_player():
	print("hit player")
	current_hp -= 1
	hit_player_emitter.emit()

func reset_hp():
	current_hp = max_hp
	reset_hp_emitter.emit()
	
func pause():
	pause_emitter.emit()
