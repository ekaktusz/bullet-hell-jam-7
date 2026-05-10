extends CanvasLayer

@onready var map: Node2D = $".."
@onready var time_label: Label = $TimeLabel
@onready var current_money_label: Label = $CurrentMoneyLabel
@onready var bullets_label: Label = $BulletsLabel
@onready var hp_1: Sprite2D = $Health/hp1
@onready var hp_2: Sprite2D = $Health/hp2
@onready var hp_3: Sprite2D = $Health/hp3
@onready var hp_4: Sprite2D = $Health/hp4
@onready var hp_5: Sprite2D = $Health/hp5

func _ready():
	GameEvents.hit_player_emitter.connect(_on_player_hit)
	GameEvents.reset_hp_emitter.connect(_on_reset_hp)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_label.text = "TIME: " + str(int(map.run_time * SkillDatabase.reward_multiplier))
	current_money_label.text = "current_money: " + str(CommonGlobals.current_money)
	bullets_label.text = str(map.bullet_manager.bullets.size()) + " / " + str(SkillDatabase.max_bullet_count)

func _on_player_hit():
	match GameEvents.current_hp:
		4:
			hp_1.hide()
		3:
			hp_2.hide()
		2:
			hp_3.hide()
		2:
			hp_4.hide()
		1:
			hp_5.hide()
			
func _on_reset_hp():
	hp_1.show()
	hp_2.show()
	hp_3.show()
	hp_4.show()
	hp_5.show()
