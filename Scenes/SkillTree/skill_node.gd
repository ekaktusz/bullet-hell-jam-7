extends TextureButton

@onready var label: Label = $Label
@onready var cost_label = $CostLabel
@onready var level_label: Label = $LevelLabel


@export var skill_id:String = "rapid_fire"
var skill_data: Skill

func _ready():
	skill_data = SkillDatabase.skills_map[skill_id]
	label.text = skill_data.name
	cost_label.text = str(skill_data.cost)
	level_label.text = str(skill_data.current_level) + "/" + str(skill_data.max_level)
	update_visual()

func update_visual():
	#self.texture_normal = skill_data.unlocked_image
	level_label.text = str(skill_data.current_level) + "/" + str(skill_data.max_level)
	disabled = true
	if SkillDatabase.can_unlock_skill(skill_id):
		self.texture_normal = skill_data.unlocked_image
		self.texture_hover = skill_data.unlocked_image
		disabled = false
	elif SkillDatabase.skill_maxed(skill_id):
		self.texture_normal = skill_data.unlocked_image
		self.texture_hover = skill_data.unlocked_image
		disabled = true
	else:
		self.texture_normal = skill_data.gray_image
		self.texture_hover = skill_data.gray_image
		disabled = true

func _on_pressed() -> void:
	print("pressed")
	SkillDatabase.unlock_skill(skill_data)
	SkillDatabase.refresh_tree.emit()
