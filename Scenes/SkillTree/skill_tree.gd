extends Control

const SKILL_NODE = preload("res://Scenes/SkillTree/skill_node.tscn")

@onready var lines = $Lines
@onready var nodes = $Nodes

func _ready():
	add_to_group("skill_tree")
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	build_tree()

func get_depth(skill_id: String) -> int:
	var skill = Progression.skills[skill_id]
	if skill["requires"].is_empty():
		return 0
	var max_depth = 0
	for req in skill["requires"]:
		max_depth = max(max_depth, get_depth(req) + 1)
	return max_depth

func build_tree():
	for child in nodes.get_children():
		child.queue_free()
	for child in lines.get_children():
		child.queue_free()
	var nodes_by_depth = {}
	for skill_id in Progression.skills.keys():
		var depth = get_depth(skill_id)
		if !nodes_by_depth.has(depth):
			nodes_by_depth[depth] = []
		nodes_by_depth[depth].append(skill_id)
	var x_spacing = 300
	var y_spacing = 140
	var viewport_size = get_viewport_rect().size
	var center_y = viewport_size.y / 2.0
	for depth in nodes_by_depth.keys():
		var layer = nodes_by_depth[depth]
		var total_height = (layer.size() - 1) * y_spacing
		for i in range(layer.size()):
			var skill_id = layer[i]
			var node = SKILL_NODE.instantiate()
			var tree_width = nodes_by_depth.keys().size() * x_spacing
			var start_x = (viewport_size.x - tree_width) / 2.0
			var x = start_x + depth * x_spacing
			var y = center_y - total_height / 2 + i * y_spacing
			node.position = Vector2(x, y)
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
	var node_map = {}
	for n in nodes.get_children():
		node_map[n.skill_id] = n
	for skill_id in Progression.skills.keys():
		var skill_data = Progression.skills[skill_id]
		for requirement in skill_data["requires"]:
			if !node_map.has(requirement):
				continue
			if !node_map.has(skill_id):
				continue
			var from_node = node_map[requirement]
			var to_node = node_map[skill_id]
			var line = Line2D.new()
			line.add_point(from_node.position + Vector2(180, 30))
			line.add_point(to_node.position + Vector2(0, 30))
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
