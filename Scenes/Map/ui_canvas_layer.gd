extends CanvasLayer
@onready var map: Node2D = $".."
@onready var time_label: Label = $TimeLabel
@onready var bullets_label: Label = $BulletsLabel
@onready var hp_1: Sprite2D = $Health/hp1
@onready var hp_2: Sprite2D = $Health/hp2
@onready var hp_3: Sprite2D = $Health/hp3
@onready var hp_4: Sprite2D = $Health/hp4
@onready var hp_5: Sprite2D = $Health/hp5

func _ready():
	GameEvents.hit_player_emitter.connect(_on_player_hit)
	GameEvents.reset_hp_emitter.connect(_on_reset_hp)

func _process(delta: float) -> void:
	time_label.text = "TIME: " + str(int(map.run_time * SkillDatabase.reward_multiplier))
	
	var current = map.bullet_manager.bullets.size()
	var max_bullets = SkillDatabase.max_bullet_count
	bullets_label.text = str(current) + " / " + str(max_bullets)
	bullets_label.add_theme_color_override("font_color", _bullet_color(current, max_bullets))

func _bullet_color(current: int, max_bullets: int) -> Color:
	if max_bullets == 0:
		return Color.WHITE
	var fill := float(current) / float(max_bullets)
	if fill < 0.6:
		return Color.WHITE
	elif fill < 0.75:
		return Color.YELLOW
	elif fill < 0.9:
		return Color(1.0, 0.5, 0.0)  # orange
	else:
		return Color.RED

func _on_player_hit():
	match GameEvents.current_hp:
		4:
			hp_1.hide()
		3:
			hp_2.hide()
		2:
			hp_3.hide()
		1:
			hp_4.hide()
		0:
			hp_5.hide()
			
func _on_reset_hp():
	hp_1.show()
	hp_2.show()
	hp_3.show()
	hp_4.show()
	hp_5.show()
