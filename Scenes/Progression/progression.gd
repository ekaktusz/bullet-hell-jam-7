extends Node

signal currency_changed(value)
signal refresh_tree

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


var unlocked_skills := []
var currency := 100

var skills := {
	"max_bullet": {
		"name": "Max Bullet",
		"requires": [],
		"cost": 10,
		"gray_image" : A_GRAY,
		"unlocked_image" : A_UNLOCKED
	},
	"heavy_bullets": {
		"name": "Heavy Bullets",
		"requires": ["max_bullet"],
		"cost": 10,
		"gray_image" : F_GRAY,
		"unlocked_image" : F_UNLOCKED
	},
	"fast_bullets": {
		"name": "Fast Bullets",
		"requires": ["max_bullet"],
		"cost": 10,
		"gray_image" : G_GRAY,
		"unlocked_image" : G_UNLOCKED
	},
	"split_shot": {
		"name": "Split Shot",
		"requires": ["heavy_bullets"],
		"cost": 10,
		"gray_image" : K_GRAY,
		"unlocked_image" : K_UNLOCKED
	},
	"ghost_shot": {
		"name": "Ghost Bullet",
		"requires": ["fast_bullets"],
		"cost": 10,
		"gray_image" : H_GRAY,
		"unlocked_image" : H_UNLOCKED
	},
	"bullet_size": {
		"name": "Bullet size",
		"requires": ["ghost_shot","split_shot"],
		"cost": 10,
		"gray_image" : L_GRAY,
		"unlocked_image" : L_UNLOCKED
	},
	"reward": {
		"name": "More Reward",
		"requires": [],
		"cost": 10,
		"gray_image" : C_GRAY,
		"unlocked_image" : C_UNLOCKED
	},
	"wall_speed": {
		"name": "Wall Speed",
		"requires": ["reward"],
		"cost": 10,
		"gray_image" : D_GRAY,
		"unlocked_image" : D_UNLOCKED
	},
	"wall_size": {
		"name": "Wall Size",
		"requires": ["reward"],
		"cost": 10,
		"gray_image" : B_GRAY,
		"unlocked_image" : B_UNLOCKED
	},
	"rapid_fire": {
		"name": "Rapid Fire",
		"requires": ["wall_speed"],
		"cost": 10,
		"gray_image" : J_GRAY,
		"unlocked_image" : J_UNLOCKED
	},
	"player_speed": {
		"name": "Player Speed",
		"requires": ["wall_size"],
		"cost": 10,
		"gray_image" : E_GRAY,
		"unlocked_image" : E_UNLOCKED
	},
	"player_size": {
		"name": "Player Size",
		"requires": ["player_speed","rapid_fire"],
		"cost": 10,
		"gray_image" : M_GRAY,
		"unlocked_image" : M_UNLOCKED
	},
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
