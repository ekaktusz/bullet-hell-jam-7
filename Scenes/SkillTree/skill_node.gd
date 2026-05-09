extends TextureButton

@onready var label: Label = $Label
@onready var cost_label = $CostLabel
@onready var level_label: Label = $LevelLabel

@export var skill_id:String = "rapid_fire"
var skill_data: Skill

func _ready():
	skill_data = SkillDatabase.skills_map[skill_id]
	label.text = skill_data.name
	cost_label.text = str(skill_data.costs[skill_data.current_level])
	level_label.text = str(skill_data.current_level) + "/" + str(skill_data.max_level)
	update_visual()

func update_visual():
	#self.texture_normal = skill_data.unlocked_image
	level_label.text = str(skill_data.current_level) + "/" + str(skill_data.max_level)
	if skill_data.is_on_max_level():
		cost_label.text = "-"
	else:
		cost_label.text = str(skill_data.costs[skill_data.current_level])

	var should_be_disabled := true
	if skill_data.can_unlock():
		self.texture_normal = skill_data.unlocked_image
		self.texture_hover = skill_data.unlocked_image
		should_be_disabled = false
	elif skill_data.is_on_max_level():
		self.texture_normal = skill_data.unlocked_image
		self.texture_hover = skill_data.unlocked_image
	else:
		self.texture_normal = skill_data.gray_image
		self.texture_hover = skill_data.gray_image

	if disabled != should_be_disabled:
		disabled = should_be_disabled

func _process(_delta: float) -> void:
	update_visual()

func _on_pressed() -> void:
	print("pressed")
	skill_data.unlock()
