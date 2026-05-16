extends Node

signal player_size_skill_emitter

const A_UNLOCKED = preload("uid://bfg08aghjvm4j")
const B_UNLOCKED = preload("uid://cni27vxqonuw3")
const C_UNLOCKED = preload("uid://do4nkkntwmb82")
const D_UNLOCKED = preload("uid://3s21vp7c1r0x")
const E_UNLOCKED = preload("uid://dwvsr2p8i2ka7")
const F_UNLOCKED = preload("uid://qty72vxxm0v2")
const G_UNLOCKED = preload("uid://b45ia08qhbwe3")
const H_UNLOCKED = preload("uid://iw6gtma0i83x")
const J_UNLOCKED = preload("uid://c8c13kiip0klq")
const K_UNLOCKED = preload("uid://b511pcgdqqo0n")
const L_UNLOCKED = preload("uid://dwpu4h8vw2bua")
const M_UNLOCKED = preload("uid://cb804gj1udq2w")
const A_GRAY = preload("uid://c4ekg8tp87nwi")
const B_GRAY = preload("uid://bmct1ilbrnine")
const C_GRAY = preload("uid://big0pr76inwqw")
const D_GRAY = preload("uid://b8mcststfqfmx")
const E_GRAY = preload("uid://cxfoky0bv8s4u")
const F_GRAY = preload("uid://bmw4qutns4ldd")
const G_GRAY = preload("uid://dmmmfcfkux0y3")
const H_GRAY = preload("uid://cuce40kksb7vy")
const J_GRAY = preload("uid://cfwg6x41afie")
const K_GRAY = preload("uid://b18dd37fpvaem")
const L_GRAY = preload("uid://crebj4x8exh5h")
const M_GRAY = preload("uid://bmk7h4ctw1iqr")

const default_wall_speed = 30
const default_wall_size = 500
const default_max_bullet_count = 10
const default_player_speed = 100
const default_player_size = 0.2
const default_bullet_size = 0.3
const default_reward_multiplier = 1
##skillekkel buffolhato global valtozok
var max_bullet_count = default_max_bullet_count
var wall_speed = default_wall_speed
var wall_size = default_wall_size
var player_speed = default_player_speed
var player_size = default_player_size
var bullet_size = default_bullet_size
var reward_multiplier = default_reward_multiplier


var max_bullet_skill = Skill.new({
	"id": "max_bullet",
	"name": "Meditation",
	"costs": [5, 20, 40] as Array[int],
	"gray_image" : A_GRAY,
	"unlocked_image" : A_UNLOCKED,
	"max_level": 3,
	"current_level": 0,
	"requirements": [] as Array[SkillRequirement]
})

var heavy_bullets_skill: Skill = Skill.new({
	"id": "heavy_bullets",
	"name": "Assertivity",
	"costs": [15, 35, 80] as Array[int],
	"gray_image" : F_GRAY,
	"unlocked_image" : F_UNLOCKED,
	"max_level": 3,
	"current_level": 0,
	"requirements": [
		SkillRequirement.new({
			"id": max_bullet_skill.id,
			"level": 1
		})
	] as Array[SkillRequirement]
})

var fast_bullets_skill = Skill.new({
	"id": "fast_bullets",
	"name": "Boundaries",
	"costs": [15, 35, 80] as Array[int],
	"gray_image" : G_GRAY,
	"unlocked_image" : G_UNLOCKED,
	"max_level": 3,
	"current_level": 0,
	"requirements": [
		SkillRequirement.new({
			"id": max_bullet_skill.id,
			"level": 1
		})
	] as Array[SkillRequirement]
})

var split_shot_skill = Skill.new({
	"id": "split_shot",
	"name": "Mindfullness",
	"costs": [30, 75, 100] as Array[int],
	"gray_image" : K_GRAY,
	"unlocked_image" : K_UNLOCKED,
	"max_level": 3,
	"current_level": 0,
	"requirements": [
		SkillRequirement.new({
			"id": heavy_bullets_skill.id,
			"level": 1
		})
	] as Array[SkillRequirement]
})

var ghost_shot_skill = Skill.new({
	"id": "ghost_shot",
	"name": "Acceptance",
	"costs": [30, 75, 100] as Array[int],
	"gray_image" : H_GRAY,
	"unlocked_image" : H_UNLOCKED,
	"max_level": 3,
	"current_level": 0,
	"requirements": [
		SkillRequirement.new({
			"id": fast_bullets_skill.id,
			"level": 1
		})
	] as Array[SkillRequirement]
})

var bullet_size_skill = Skill.new({
	"id": "bullet_size",
	"name": "Dopamine Detox",
	"costs": [50, 120, 200] as Array[int],
	"gray_image" : L_GRAY,
	"unlocked_image" : L_UNLOCKED,
	"max_level": 3,
	"current_level": 0,
	"requirements": [
		SkillRequirement.new({
			"id": split_shot_skill.id,
			"level": 1
		}),
		SkillRequirement.new({
			"id": ghost_shot_skill.id,
			"level": 1
		})
	] as Array[SkillRequirement]
})

var reward_skill = Skill.new({
	"id": "reward",
	"name": "Motivation",
	"costs": [5, 20, 40] as Array[int],
	"gray_image" : C_GRAY,
	"unlocked_image" : C_UNLOCKED,
	"max_level": 3,
	"current_level": 0,
	"requirements": [] as Array[SkillRequirement]
})

var wall_speed_skill = Skill.new({
	"id": "wall_speed",
	"name": "Resilience",
	"costs": [15, 35, 80] as Array[int],
	"gray_image" : D_GRAY,
	"unlocked_image" : D_UNLOCKED,
	"max_level": 3,
	"current_level": 0,
	"requirements": [
		SkillRequirement.new({
			"id": reward_skill.id,
			"level": 1
		})
	] as Array[SkillRequirement]
})

var wall_size_skill = Skill.new({
	"id": "wall_size",
	"name": "Self Image",
	"costs": [15, 35, 80] as Array[int],
	"gray_image" : B_GRAY,
	"unlocked_image" : B_UNLOCKED,
	"max_level": 3,
	"current_level": 0,
	"requirements": [
		SkillRequirement.new({
			"id": reward_skill.id,
			"level": 1
		})
	] as Array[SkillRequirement]
})

var rapid_fire_skill = Skill.new({
	"id": "rapid_fire",
	"name": "Flow State",
	"costs": [30] as Array[int],
	"gray_image" : J_GRAY,
	"unlocked_image" : J_UNLOCKED,
	"max_level": 1,
	"current_level": 0,
	"requirements": [
		SkillRequirement.new({
			"id": wall_speed_skill.id,
			"level": 1
		})
	] as Array[SkillRequirement]
})

var player_speed_skill = Skill.new({
	"id": "player_speed",
	"name": "Long Walks",
	"costs": [30, 75, 100] as Array[int],
	"gray_image" : E_GRAY,
	"unlocked_image" : E_UNLOCKED,
	"max_level": 3,
	"current_level": 0,
	"requirements": [
		SkillRequirement.new({
			"id": wall_size_skill.id,
			"level": 1
		})
	] as Array[SkillRequirement]
})

var player_size_skill = Skill.new({
	"id": "player_size",
	"name": "Working Out",
	"costs": [50, 120, 200] as Array[int],
	"gray_image" : M_GRAY,
	"unlocked_image" : M_UNLOCKED,
	"max_level": 3,
	"current_level": 0,
	"requirements": [
		SkillRequirement.new({
			"id": player_speed_skill.id,
			"level": 1
		}),
		SkillRequirement.new({
			"id": rapid_fire_skill.id,
			"level": 1
		})
	] as Array[SkillRequirement]
})

var skills_map := {
	"max_bullet": max_bullet_skill,
	"heavy_bullets": heavy_bullets_skill,
	"fast_bullets": fast_bullets_skill,
	"split_shot": split_shot_skill,
	"ghost_shot": ghost_shot_skill,
	"bullet_size": bullet_size_skill,
	"reward": reward_skill,
	"wall_speed": wall_speed_skill,
	"wall_size": wall_size_skill,
	"rapid_fire": rapid_fire_skill,
	"player_speed": player_speed_skill,
	"player_size": player_size_skill
}

func is_all_skills_max() -> bool:
	for skill in skills_map.values():
		if !skill.is_on_max_level():
			return false
	return true
	
	
func sell_all_skills() -> void:
	CommonGlobals.has_at_least_one_skill = false
	
	for skill in skills_map.values():
		for i in range(skill.current_level):
			CommonGlobals.current_money += skill.costs[i]
		skill.current_level = 0

	# reset all upgraded values to defaults
	max_bullet_count = default_max_bullet_count
	wall_speed = default_wall_speed
	wall_size = default_wall_size
	player_speed = default_player_speed
	player_size = default_player_size
	bullet_size = default_bullet_size
	reward_multiplier = default_reward_multiplier
	# ez nem tom kell e de lehet
	player_size_skill_emitter.emit()
	#print("All skills sold and refunded.")
