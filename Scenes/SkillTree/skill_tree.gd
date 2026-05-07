extends Control

const SKILL_NODE = preload("res://Scenes/SkillTree/skill_node.tscn")

@onready var lines = $Lines
@onready var nodes = $Nodes

func _ready():
	add_to_group("skill_tree")
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	build_tree()

func build_tree():
	for child in nodes.get_children():
		child.queue_free()
	for child in lines.get_children():
		child.queue_free()
	for skill_id in Progression.skills:
		var node = SKILL_NODE.instantiate()
		nodes.add_child(node)
		node.setup(skill_id)
	draw_connections()

func refresh_tree():
	for node in nodes.get_children():
		node.update_visual()
	draw_connections()

func draw_connections():
	for child in lines.get_children():
		child.queue_free()
	for skill_id in Progression.skills:
		var skill_data = Progression.skills[skill_id]
		for requirement in skill_data["requires"]:
			var line = Line2D.new()
			var from_pos = Progression.skills[requirement]["position"] + Vector2(90, 30)
			var to_pos = skill_data["position"] + Vector2(90, 30)
			line.add_point(from_pos)
			line.add_point(to_pos)
			line.width = 4
			if Progression.has_skill(requirement):
				line.default_color = Color.WHITE
			else:
				line.default_color = Color(0.3, 0.3, 0.3)
			lines.add_child(line)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		close()

func close():
	get_tree().paused = false
	queue_free()

func _on_restart_pressed():
	print("RESTART CLICKED")
	get_tree().paused = false
	get_tree().reload_current_scene()
