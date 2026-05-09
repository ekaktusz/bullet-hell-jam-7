extends Node

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


var current_money := 100

var max_bullet_skill = Skill.new({
	"id": "max_bullet",
	"name": "Max Bullet",
	"costs": [10] as Array[int],
	"gray_image" : A_GRAY,
	"unlocked_image" : A_UNLOCKED,
	"max_level": 1,
	"current_level": 0,
	"requirements": [] as Array[SkillRequirement]
})

var heavy_bullets_skill: Skill = Skill.new({
	"id": "heavy_bullets",
	"name": "Heavy Bullets",
	"costs": [10, 15, 20, 25, 30] as Array[int],
	"gray_image" : F_GRAY,
	"unlocked_image" : F_UNLOCKED,
	"max_level": 5,
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
	"name": "Fast Bullets",
	"costs": [10, 15, 20, 25, 30] as Array[int],
	"gray_image" : G_GRAY,
	"unlocked_image" : G_UNLOCKED,
	"max_level": 5,
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
	"name": "Split Shot",
	"costs": [10, 15, 20, 25, 30] as Array[int],
	"gray_image" : K_GRAY,
	"unlocked_image" : K_UNLOCKED,
	"max_level": 5,
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
	"name": "Ghost Bullet",
	"costs": [10, 15, 20, 25, 30] as Array[int],
	"gray_image" : H_GRAY,
	"unlocked_image" : H_UNLOCKED,
	"max_level": 5,
	"current_level": 0,
	"requirements": [
		SkillRequirement.new({
			"id": fast_bullets_skill.id,
			"level": 5
		})
	] as Array[SkillRequirement]
})

var bullet_size_skill = Skill.new({
	"id": "bullet_size",
	"name": "Bullet Size",
	"costs": [10, 15, 20, 25, 30] as Array[int],
	"gray_image" : M_GRAY,
	"unlocked_image" : M_UNLOCKED,
	"max_level": 5,
	"current_level": 0,
	"requirements": [
		SkillRequirement.new({
			"id": split_shot_skill.id,
			"level": 5
		}),
		SkillRequirement.new({
			"id": ghost_shot_skill.id,
			"level": 5
		})
	] as Array[SkillRequirement]
})

var reward_skill = Skill.new({
	"id": "reward",
	"name": "More Reward",
	"costs": [10, 15, 20, 25, 30] as Array[int],
	"gray_image" : C_GRAY,
	"unlocked_image" : C_UNLOCKED,
	"max_level": 5,
	"current_level": 0,
	"requirements": [] as Array[SkillRequirement]
})

var wall_speed_skill = Skill.new({
	"id": "wall_speed",
	"name": "Wall Speed",
	"costs": [10, 15, 20, 25, 30] as Array[int],
	"gray_image" : D_GRAY,
	"unlocked_image" : D_UNLOCKED,
	"max_level": 5,
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
	"name": "Wall Size",
	"costs": [10, 15, 20, 25, 30] as Array[int],
	"gray_image" : E_GRAY,
	"unlocked_image" : E_UNLOCKED,
	"max_level": 5,
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
	"name": "Rapid Fire",
	"costs": [10, 15, 20, 25, 30] as Array[int],
	"gray_image" : J_GRAY,
	"unlocked_image" : J_UNLOCKED,
	"max_level": 5,
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
	"name": "Player Speed",
	"costs": [10, 15, 20, 25, 30] as Array[int],
	"gray_image" : E_GRAY,
	"unlocked_image" : E_UNLOCKED,
	"max_level": 5,
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
	"name": "Player Size",
	"costs": [10, 15, 20, 25, 30] as Array[int],
	"gray_image" : M_GRAY,
	"unlocked_image" : M_UNLOCKED,
	"max_level": 5,
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
