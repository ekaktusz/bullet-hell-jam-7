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
		match id:
			"max_bullet":
				handle_max_bullet_level_up()
			"bullet_size":
				handle_bullet_size_level_up()
			"reward":
				handle_reward_level_up()
			"wall_speed":
				handle_wall_speed_level_up()	
			"wall_size":
				handle_wall_size_level_up()
			"player_speed":
				handle_player_speed_level_up()
			"player_size":
				handle_player_size_level_up()

func handle_max_bullet_level_up():
	if current_level == 1:
			SkillDatabase.max_bullet_count = 20
	if current_level == 2:
			SkillDatabase.max_bullet_count = 50	
	if current_level == 3:
			SkillDatabase.max_bullet_count = 100			
	print(SkillDatabase.max_bullet_count)
				
func handle_wall_speed_level_up():
	if current_level == 1:
			SkillDatabase.wall_speed = 80
	if current_level == 2:
			SkillDatabase.wall_speed = 60	
	if current_level == 3:
			SkillDatabase.wall_speed = 50	

func handle_wall_size_level_up():
	if current_level == 1:
			SkillDatabase.wall_size = 600
	if current_level == 2:
			SkillDatabase.wall_size = 700	
	if current_level == 3:
			SkillDatabase.wall_size = 800	


func handle_player_speed_level_up():
	if current_level == 1:
			SkillDatabase.player_speed = 200
	if current_level == 2:
			SkillDatabase.player_speed = 300
	if current_level == 3:
			SkillDatabase.player_speed = 500

func handle_player_size_level_up():
	if current_level == 1:
			SkillDatabase.player_size = 0.8
	if current_level == 2:
			SkillDatabase.player_size = 0.6
	if current_level == 3:
			SkillDatabase.player_size = 0.4
			SkillDatabase.player_size_skill_emitter.emit()

func handle_bullet_size_level_up():
	if current_level == 1:
			SkillDatabase.bullet_size = 0.25
	if current_level == 2:
			SkillDatabase.bullet_size = 0.2
	if current_level == 3:
			SkillDatabase.bullet_size = 0.15
	print(SkillDatabase.bullet_size)
	
func handle_reward_level_up():
	if current_level == 1:
			SkillDatabase.reward_multiplier = 1.2
	if current_level == 2:
			SkillDatabase.reward_multiplier = 1.5
	if current_level == 3:
			SkillDatabase.reward_multiplier = 2
