extends Node2D

@onready var label: Label = $Label

var is_good = true

var good_thoughts = ["SZÉP", "SZERETNEK", "ÜGYES"]
var bad_thoughts = ["BÉNA", "LÚZER", "KEVÉS"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var value = randi_range(0, 2)
	if is_good:
		label.text = good_thoughts[value]
		label.add_theme_color_override("font_color", Color.CHARTREUSE)
	else:
		label.text = bad_thoughts[value]
		label.add_theme_color_override("font_color", Color.CRIMSON)

func remove():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
