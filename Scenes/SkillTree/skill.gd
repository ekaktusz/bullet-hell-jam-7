class_name Skill

var id: String
var name: String
var cost: int
var gray_image: Resource
var unlocked_image: Resource
var max_level: int
var current_level: int
var requirements: Array[SkillRequirement]

func _init(config := {}):
	id = config.get("id", id)
	name = config.get("name", name)
	cost = config.get("cost", cost)
	gray_image = config.get("gray_image", gray_image)
	unlocked_image = config.get("unlocked_image", unlocked_image)
	max_level = config.get("max_level", max_level)
	current_level = config.get("current_level", current_level)
	var reqs: Array = config.get("requirements", [])
	requirements = reqs as Array[SkillRequirement]
	
	
func level_up() -> void:
	if current_level < max_level:
		current_level += 1

func can_unlock(current_money: int) -> bool:
	if current_level >= max_level:
		return false
	if current_money < cost:
		return false
	# Check all requirements
	for requirement in requirements:
		var id_required_skill: String = requirement.id
		var current_level_of_required_skill: int = SkillDatabase.skills_map[id_required_skill].current_level
		if current_level_of_required_skill < requirement.level:
			return false
	return true
