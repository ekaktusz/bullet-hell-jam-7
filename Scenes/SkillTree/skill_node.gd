extends TextureButton

@onready var label: Label = $Label
@onready var cost_label = $CostLabel

@export var skill_id:String = "rapid_fire"
var skill_data = ""
func _ready():
	skill_data = Progression.skills[skill_id]
	label.text = skill_data["name"]
	cost_label.text = str(skill_data["cost"])
	update_visual()

func update_visual():
	if Progression.has_skill(skill_id):
		self.texture_normal = skill_data.unlocked_image
		disabled = true
	elif Progression.can_unlock(skill_id):
		self.texture_normal = skill_data.gray_image
		self.texture_hover = skill_data.unlocked_image
		disabled = false
	else:
		self.texture_normal = skill_data.gray_image
		disabled = true

func _on_pressed() -> void:
	print("pressed")
	Progression.unlock_skill(skill_id)
	Progression.refresh_tree.emit()
