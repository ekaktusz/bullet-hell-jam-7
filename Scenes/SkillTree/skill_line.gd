extends Line2D

@export var skill_to: String = "fast_bullets"
@export var skill_from: String = "fast_bullets"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if SkillDatabase.skills_map[skill_to].pre_skill_requirement_satisfied():
		width = 10
