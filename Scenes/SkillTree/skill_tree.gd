extends Control

signal restart_run

const SKILL_NODE = preload("res://Scenes/SkillTree/skill_node.tscn")

@onready var lines = $Lines
@onready var nodes = $Nodes

func _on_restart_pressed():
	print("RESTART CLICKED")
	get_tree().paused = false
	restart_run.emit()
