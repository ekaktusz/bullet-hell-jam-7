extends Control

signal restart_run

const SKILL_NODE = preload("res://Scenes/SkillTree/skill_node.tscn")

@onready var sell_skills: Button = $SellSkills


func _process(delta: float) -> void:
	print(CommonGlobals.has_at_least_one_skill)
	sell_skills.disabled = not CommonGlobals.has_at_least_one_skill

func _on_restart_pressed():
	print("RESTART CLICKED")
	get_tree().paused = false
	restart_run.emit()


func _on_sell_skills_pressed() -> void:
	SkillDatabase.sell_all_skills()
