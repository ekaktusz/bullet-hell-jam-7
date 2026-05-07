extends Button

@onready var label: Label = $Label

var skill_id := ""

func setup(id: String):
	skill_id = id
	var skill_data = Progression.skills[id]
	label.text = skill_data["name"]
	position = skill_data["position"]
	update_visual()

func update_visual():
	if Progression.has_skill(skill_id):
		modulate = Color(0.3, 1.0, 0.3)
		disabled = true
	elif Progression.can_unlock(skill_id):
		modulate = Color(1.0, 0.85, 0.2)
		disabled = false
	else:
		modulate = Color(0.25, 0.25, 0.25)
		disabled = true

func _pressed():
	Progression.unlock_skill(skill_id)
	get_tree().get_first_node_in_group("skill_tree").refresh_tree()
