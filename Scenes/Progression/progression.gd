extends Node

var unlocked_skills := {}

var skills := {
	"rapid_fire": {
		"name": "Rapid Fire",
		"requires": [],
	},
	"heavy_bullets": {
		"name": "Heavy Bullets",
		"requires": ["rapid_fire"],
	},
	"fast_bullets": {
		"name": "Fast Bullets",
		"requires": ["rapid_fire"],
	},
	"split_shot": {
		"name": "Split Shot",
		"requires": ["fast_bullets"],
	}
}

func has_skill(id: String) -> bool:
	return unlocked_skills.get(id, false)

func unlock_skill(id: String):
	if can_unlock(id):
		unlocked_skills[id] = true
		print("UNLOCKED: ", id)

func can_unlock(id: String) -> bool:
	if has_skill(id):
		return false
	var requirements = skills[id]["requires"]
	for requirement in requirements:
		if !has_skill(requirement):
			return false
	return true
	
func get_depth(skill_id: String) -> int:
	var skill = Progression.skills[skill_id]
	if skill["requires"].is_empty():
		return 0
	var max_depth = 0
	for req in skill["requires"]:
		max_depth = max(max_depth, get_depth(req) + 1)
	return max_depth
