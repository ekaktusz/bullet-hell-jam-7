extends Node

signal currency_changed(value)

var unlocked_skills := []
var currency := 0

var skills := {
	"rapid_fire": {
		"name": "Rapid Fire",
		"requires": [],
		"cost": 10,
	},
	"heavy_bullets": {
		"name": "Heavy Bullets",
		"requires": ["rapid_fire"],
		"cost": 10,
	},
	"fast_bullets": {
		"name": "Fast Bullets",
		"requires": ["rapid_fire"],
		"cost": 10,
	},
	"split_shot": {
		"name": "Split Shot",
		"requires": ["fast_bullets", "heavy_bullets"],
		"cost": 10,
	},
	"kamu": {
		"name": "Kamu",
		"requires": ["split_shot"],
		"cost": 10,
	}
}

func has_skill(id: String) -> bool:
	return id in unlocked_skills

func unlock_skill(skill_id: String):
	if !can_unlock(skill_id):
		return
	var skill = skills[skill_id]
	currency -= skill["cost"]
	unlocked_skills.append(skill_id)
	currency_changed.emit(currency)
	print("UNLOCKED:", skill_id)
	print("CURRENCY:", currency)

func can_unlock(skill_id: String) -> bool:
	if has_skill(skill_id):
		return false
	var skill = skills[skill_id]
	for requirement in skill["requires"]:
		if !has_skill(requirement):
			return false
	if currency < skill["cost"]:
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

func add_currency(amount: int):
	currency += amount
	currency_changed.emit(currency)
