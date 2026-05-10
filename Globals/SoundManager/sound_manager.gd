extends Node

enum Sound {
	NORMAL_BULLET,
	SPREAD_BULLET,
	HEAVY_BULLET,
	FAST_BULLET,
	GHOST_BULLET,
	SKILL_PICKUP,
	DEATH,
	REWARD_PICKUP,
	NO_MORE_BALLS,
	NO_MONEY,
	MOVEMENT,
	BRAIN_DMG,
	BALL_BOUNCE,
	BALL_BOUNCE_FUN
}

@export var normal_bullet_sound: AudioStream
@export var spread_bullet_sound: AudioStream
@export var heavy_bullet_sound: AudioStream
@export var fast_bullet_sound: AudioStream
@export var ghost_bullet_sound: AudioStream
@export var skill_pickup_sound: AudioStream
@export var death_sound: AudioStream
@export var reward_pickup_sound: AudioStream
@export var no_more_balls_sound: AudioStream
@export var no_money_sound: AudioStream
@export var movement_sound: AudioStream
@export var brain_dmg_sound: AudioStream
@export var ball_bounce_sound: AudioStream
@export var ball_bounce_fun_sound: AudioStream
@onready var sfx_player: AudioStreamPlayer = $SfxPlayer
var sound_library: Dictionary
var active_sounds = {}


func _ready() -> void:
	sound_library.set(Sound.NORMAL_BULLET, normal_bullet_sound)
	sound_library.set(Sound.SPREAD_BULLET, spread_bullet_sound)
	sound_library.set(Sound.HEAVY_BULLET, heavy_bullet_sound)
	sound_library.set(Sound.FAST_BULLET, fast_bullet_sound)
	sound_library.set(Sound.GHOST_BULLET, ghost_bullet_sound)
	sound_library.set(Sound.SKILL_PICKUP, skill_pickup_sound)
	sound_library.set(Sound.DEATH, death_sound)
	sound_library.set(Sound.REWARD_PICKUP, reward_pickup_sound)
	sound_library.set(Sound.NO_MORE_BALLS, no_more_balls_sound)
	sound_library.set(Sound.NO_MONEY, no_money_sound)
	sound_library.set(Sound.MOVEMENT, movement_sound)
	sound_library.set(Sound.BRAIN_DMG, brain_dmg_sound)
	sound_library.set(Sound.BALL_BOUNCE, ball_bounce_sound)
	sound_library.set(Sound.BALL_BOUNCE_FUN, ball_bounce_fun_sound)

func play_sound_by_id(id: Sound, bus: String = "SFX"):
	var stream = sound_library.get(id)
	return play_sfx(stream, bus)


func play_sfx(stream: AudioStream, bus: String) -> AudioStreamPlayer:
	if active_sounds.has(stream) and active_sounds[stream].is_playing():
		return active_sounds[stream]

	var new_player = AudioStreamPlayer.new()
	add_child(new_player)

	new_player.bus = bus
	new_player.stream = stream
	new_player.play()

	active_sounds[stream] = new_player

	new_player.finished.connect(
		func():
			active_sounds.erase(stream)
			new_player.queue_free()
	)

	return new_player
