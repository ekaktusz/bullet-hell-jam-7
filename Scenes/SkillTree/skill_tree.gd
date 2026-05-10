extends Control

signal restart_run

const SKILL_NODE = preload("res://Scenes/SkillTree/skill_node.tscn")
@onready var current_money_label: Label = $CurrentMoneyLabel

@onready var left_skill_1: TextureButton = $Nodes/A
@onready var left_skill_2a: TextureButton = $Nodes/F
@onready var left_skill_2b: TextureButton = $Nodes/G
@onready var left_skill_3a: TextureButton = $Nodes/K
@onready var left_skill_3b: TextureButton = $Nodes/H
@onready var left_skill_4: TextureButton = $Nodes/L

@onready var right_skill_1: TextureButton = $Nodes/C
@onready var right_skill_2a: TextureButton = $Nodes/B
@onready var right_skill_2b: TextureButton = $Nodes/D
@onready var right_skill_3a: TextureButton = $Nodes/E
@onready var right_skill_3b: TextureButton = $Nodes/J
@onready var right_skill_4: TextureButton = $Nodes/M

@onready var restart_button: Button = $Restart


@onready var sell_skills: Button = $SellSkills

func _ready() -> void:
	# --- restart ---
	restart_button.focus_neighbor_left  = left_skill_1.get_path()
	restart_button.focus_neighbor_right = right_skill_1.get_path()
	restart_button.focus_neighbor_top   = left_skill_1.get_path()   # or right, pick one

	# --- sell_skills ---
	sell_skills.focus_neighbor_bottom = left_skill_4.get_path()      # or right_skill_4

	# === LEFT TREE ===

	# left_skill_1 (bottom of left tree)
	left_skill_1.focus_neighbor_bottom = restart_button.get_path()
	left_skill_1.focus_neighbor_top    = left_skill_2a.get_path()
	left_skill_1.focus_neighbor_left   = left_skill_2a.get_path()
	left_skill_1.focus_neighbor_right  = right_skill_1.get_path()

	# left_skill_2a (left branch, row 2)
	left_skill_2a.focus_neighbor_bottom = left_skill_1.get_path()
	left_skill_2a.focus_neighbor_top    = left_skill_3a.get_path()
	left_skill_2a.focus_neighbor_left   = left_skill_2a.get_path()   # edge, wrap to self or leave default
	left_skill_2a.focus_neighbor_right  = left_skill_2b.get_path()

	# left_skill_2b (right branch, row 2)
	left_skill_2b.focus_neighbor_bottom = left_skill_1.get_path()
	left_skill_2b.focus_neighbor_top    = left_skill_3b.get_path()
	left_skill_2b.focus_neighbor_left   = left_skill_2a.get_path()
	left_skill_2b.focus_neighbor_right  = right_skill_2a.get_path()

	# left_skill_3a (left branch, row 3)
	left_skill_3a.focus_neighbor_bottom = left_skill_2a.get_path()
	left_skill_3a.focus_neighbor_top    = left_skill_4.get_path()
	left_skill_3a.focus_neighbor_left   = left_skill_3a.get_path()   # edge
	left_skill_3a.focus_neighbor_right  = left_skill_3b.get_path()

	# left_skill_3b (right branch, row 3)
	left_skill_3b.focus_neighbor_bottom = left_skill_2b.get_path()
	left_skill_3b.focus_neighbor_top    = left_skill_4.get_path()
	left_skill_3b.focus_neighbor_left   = left_skill_3a.get_path()
	left_skill_3b.focus_neighbor_right  = right_skill_3a.get_path()

	# left_skill_4 (top of left tree)
	left_skill_4.focus_neighbor_bottom = left_skill_3a.get_path()
	left_skill_4.focus_neighbor_top    = sell_skills.get_path()
	left_skill_4.focus_neighbor_left   = left_skill_4.get_path()     # edge
	left_skill_4.focus_neighbor_right  = right_skill_4.get_path()

	# === RIGHT TREE ===

	# right_skill_1 (bottom of right tree)
	right_skill_1.focus_neighbor_bottom = restart_button.get_path()
	right_skill_1.focus_neighbor_top    = right_skill_2a.get_path()
	right_skill_1.focus_neighbor_left   = left_skill_1.get_path()
	right_skill_1.focus_neighbor_right  = right_skill_2b.get_path()

	# right_skill_2a (left branch, row 2)
	right_skill_2a.focus_neighbor_bottom = right_skill_1.get_path()
	right_skill_2a.focus_neighbor_top    = right_skill_3a.get_path()
	right_skill_2a.focus_neighbor_left   = left_skill_2b.get_path()
	right_skill_2a.focus_neighbor_right  = right_skill_2b.get_path()

	# right_skill_2b (right branch, row 2)
	right_skill_2b.focus_neighbor_bottom = right_skill_1.get_path()
	right_skill_2b.focus_neighbor_top    = right_skill_3b.get_path()
	right_skill_2b.focus_neighbor_left   = right_skill_2a.get_path()
	right_skill_2b.focus_neighbor_right  = right_skill_2b.get_path() # edge

	# right_skill_3a (left branch, row 3)
	right_skill_3a.focus_neighbor_bottom = right_skill_2a.get_path()
	right_skill_3a.focus_neighbor_top    = right_skill_4.get_path()
	right_skill_3a.focus_neighbor_left   = left_skill_3b.get_path()
	right_skill_3a.focus_neighbor_right  = right_skill_3b.get_path()

	# right_skill_3b (right branch, row 3)
	right_skill_3b.focus_neighbor_bottom = right_skill_2b.get_path()
	right_skill_3b.focus_neighbor_top    = right_skill_4.get_path()
	right_skill_3b.focus_neighbor_left   = right_skill_3a.get_path()
	right_skill_3b.focus_neighbor_right  = right_skill_3b.get_path() # edge

	# right_skill_4 (top of right tree)
	right_skill_4.focus_neighbor_bottom = right_skill_3a.get_path()
	right_skill_4.focus_neighbor_top    = sell_skills.get_path()
	right_skill_4.focus_neighbor_left   = left_skill_4.get_path()
	right_skill_4.focus_neighbor_right  = right_skill_4.get_path()   # edge
	
func opened() -> void:
	if CommonGlobals.controller_support_on:
		restart_button.grab_focus()

func _process(delta: float) -> void:
	sell_skills.disabled = not CommonGlobals.has_at_least_one_skill
	current_money_label.text = str(CommonGlobals.current_money)

func _on_restart_pressed():
	print("RESTART CLICKED")
	get_tree().paused = false
	restart_run.emit()


func _on_sell_skills_pressed() -> void:
	SkillDatabase.sell_all_skills()
