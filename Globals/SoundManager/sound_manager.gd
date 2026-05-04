extends Node

@export var click_sound: AudioStream

@onready var sfx_player: AudioStreamPlayer = $SfxPlayer


func _ready() -> void:
	sfx_player.max_polyphony = 4


func play_sfx(stream: AudioStream) -> AudioStreamPlayer:
	sfx_player.stream = stream
	sfx_player.play()
	return sfx_player


func play_click_sound() -> AudioStreamPlayer:
	return play_sfx(click_sound)
