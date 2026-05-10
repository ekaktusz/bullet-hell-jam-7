extends Node

const BRAINROT_002_CHILL = preload("uid://byobagmofk76")
const BRAINROT_002_HARD = preload("uid://chkq28tmv0oxc")

const SILENCE_DB = -80.0
const NORMAL_DB = 0.0

@onready var audio_stream_player = $AudioStreamPlayer


func play_chill_music() -> void:
	audio_stream_player.stream = BRAINROT_002_CHILL
	audio_stream_player.play()


func play_hard_music() -> void:
	audio_stream_player.stream = BRAINROT_002_HARD
	audio_stream_player.play()
