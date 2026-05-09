class_name Skill

var id: String
var name: String
var costs: Array[int]
var gray_image: Resource
var unlocked_image: Resource
var max_level: int
var current_level: int
var requirements: Array[SkillRequirement]

func _init(config := {}):
	id = config.get("id", id)
	name = config.get("name", name)
	costs = config.get("costs", costs) as Array[int]
	gray_image = config.get("gray_image", gray_image)
	unlocked_image = config.get("unlocked_image", unlocked_image)
	max_level = config.get("max_level", max_level)
	current_level = config.get("current_level", current_level)
	var reqs: Array = config.get("requirements", [])
	requirements = reqs as Array[SkillRequirement]

func is_on_max_level() -> bool:
	return current_level >= max_level
	
func level_up() -> void:
	if not is_on_max_level():
		current_level += 1
	
	print("skill level up", current_level, "/", max_level)
		
func is_unlocked() -> bool:
	return current_level > 0
		
func pre_skill_requirement_satisfied() -> bool:
	for requirement in requirements:
		var id_required_skill: String = requirement.id
		var current_level_of_required_skill: int = SkillDatabase.skills_map[id_required_skill].current_level
		if current_level_of_required_skill < requirement.level:
			return false
	return true

func can_unlock() -> bool:
	if current_level >= max_level:
		return false
	if CommonGlobals.current_money < costs[current_level]:
		return false
	# Check all requirements
	if not pre_skill_requirement_satisfied():
		return false
	return true

func unlock() -> void:
	if can_unlock():
		CommonGlobals.current_money -= costs[current_level]
		level_up()
