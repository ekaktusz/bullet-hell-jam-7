class_name SkillRequirement

var id: String
var level: int

func _init(config := {}):
	id = config.get("id", id)
	level = config.get("level", level)
