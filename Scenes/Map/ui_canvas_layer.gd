extends CanvasLayer

@onready var map: Node2D = $".."
@onready var time_label: Label = $TimeLabel
@onready var current_money_label: Label = $CurrentMoneyLabel
@onready var bullets_label: Label = $BulletsLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_label.text = "TIME: " + str(int(map.run_time * SkillDatabase.reward_multiplier))
	current_money_label.text = "current_money: " + str(CommonGlobals.current_money)
	bullets_label.text = str(map.bullet_manager.bullets.size()) + " / " + str(SkillDatabase.max_bullet_count)
