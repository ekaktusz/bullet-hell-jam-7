extends Node

var unlocked_skills := {
	"rapid_fire": false,
	"heavy_bullets": false,
	"fast_bullets": false,
}

var currency := 0

func has_skill(id: String) -> bool:
	return unlocked_skills.get(id, false)

func unlock_skill(id: String):
	unlocked_skills[id] = true
