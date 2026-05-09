extends Control

signal restart_run

const SKILL_NODE = preload("res://Scenes/SkillTree/skill_node.tscn")

@onready var lines = $Lines
@onready var nodes = $Nodes

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	#build_tree()

func get_depth(skill_id: String) -> int:
	var skill = Progression.skills[skill_id]
	if skill["requires"].is_empty():
		return 0
	var max_depth = 0
	for req in skill["requires"]:
		max_depth = max(max_depth, get_depth(req) + 1)
	return max_depth

func refresh_tree():
	for node in nodes.get_children():
		node.update_visual()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		close()

func close():
	get_tree().paused = false
	queue_free()

func _on_restart_pressed():
	print("RESTART CLICKED")
	get_tree().paused = false
	restart_run.emit()
