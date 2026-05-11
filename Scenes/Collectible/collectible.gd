class_name Collectible
extends Area2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@export var base_value := 10

var map_ref: Node2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _process(_delta: float) -> void:
	if map_ref == null:
		return

	if !Geometry2D.is_point_in_polygon(position, map_ref.points):
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player"):
		return
	#print("REWARD PICKED:")
	GameEvents.reset_hp()
	animation.play("pickup")
	SoundManager.play_sound_by_id(SoundManager.Sound.REWARD_PICKUP)
	animation.animation_finished.connect(_on_anim_finished)
	
func _on_anim_finished() -> void:
	queue_free()
