class_name Collectible
extends Area2D

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
	var amount := int(base_value * SkillDatabase.reward_multiplier)
	CommonGlobals.current_money += amount
	print("REWARD PICKED:", amount)
	queue_free()
