extends CanvasLayer

@onready var map: Node2D = $".."
@onready var time_label: Label = $TimeLabel
@onready var current_money_label: Label = $CurrentMoneyLabel
@onready var bullets_label: Label = $BulletsLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_label.text = "TIME: " + str(int(map.run_time))
	current_money_label.text = "current_money: " + str(SkillDatabase.current_money)
	bullets_label.text = str(map.bullet_manager.bullets.size()) + " / " + str(map.bullet_manager.max_bullet_count)
