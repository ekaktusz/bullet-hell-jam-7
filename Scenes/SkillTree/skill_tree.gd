extends Control

signal restart_run

const SKILL_NODE = preload("res://Scenes/SkillTree/skill_node.tscn")

@onready var lines = $Lines
@onready var nodes = $Nodes

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	#build_tree()


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
