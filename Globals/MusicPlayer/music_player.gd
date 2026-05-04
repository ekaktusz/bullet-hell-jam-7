extends Node

@onready var audio_stream_player = $AudioStreamPlayer


func _ready() -> void:
	pass


func start_music() -> void:
	audio_stream_player.play()
