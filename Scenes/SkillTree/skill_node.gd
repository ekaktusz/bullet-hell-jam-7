extends TextureButton

@onready var label: Label = $Label
@onready var cost_label: Label = $CostLabel
@onready var level_label: Label = $LevelLabel
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var progress_bar: ProgressBar = $ProgressBar

@export var skill_id: String = "rapid_fire"

var skill_data: Skill
var _base_scale: Vector2

const PULSE_PERIOD    := 1.7
const PULSE_MIN_ALPHA := 0.6
const PULSE_MAX_ALPHA := 1.0

const COLOR_MAXED     := Color(1.00, 0.85, 0.25, 1.0)
const COLOR_AVAILABLE := Color(1.00, 1.00, 1.00, 1.0)
const COLOR_UNLOCKED  := Color(0.55, 0.80, 0.95, 1.0)
const COLOR_LOCKED    := Color(0.18, 0.18, 0.22, 1.0)

const LIGHT_COLOR_MAXED     := Color(1.0, 0.75, 0.15)
const LIGHT_COLOR_AVAILABLE := Color(0.3, 0.60, 1.00)
const LIGHT_ENERGY_MAXED     := 0.9
const LIGHT_ENERGY_AVAILABLE := 0.5

const LABEL_SCALE_NORMAL := Vector2(1.0, 1.0)
const LABEL_SCALE_HOVER  := Vector2(1.15, 1.15)


func _ready():
	_base_scale = scale
	skill_data = SkillDatabase.skills_map[skill_id]
	progress_bar.max_value = skill_data.max_level
	label.text = skill_data.name
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)

	label.pivot_offset = label.size / 2
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	update_visual()


func update_visual() -> void:
	progress_bar.value = skill_data.current_level
	level_label.text = str(skill_data.current_level) + "/" + str(skill_data.max_level)

	if skill_data.is_on_max_level():
		cost_label.text = "MAX"
	else:
		cost_label.text = str(skill_data.costs[skill_data.current_level]) + " pts"

	texture_normal   = skill_data.unlocked_image
	texture_hover    = skill_data.unlocked_image
	texture_pressed  = skill_data.unlocked_image
	texture_disabled = skill_data.unlocked_image

	# ── MAXED OUT ────────────────────────────────────────────
	if skill_data.is_on_max_level():
		self_modulate          = COLOR_MAXED
		point_light_2d.visible = true
		point_light_2d.color   = LIGHT_COLOR_MAXED
		point_light_2d.energy  = LIGHT_ENERGY_MAXED
		disabled               = true

	# ── AVAILABLE TO BUY ─────────────────────────────────────
	elif skill_data.can_unlock():
		self_modulate          = Color(COLOR_AVAILABLE.r, COLOR_AVAILABLE.g, COLOR_AVAILABLE.b, self_modulate.a)
		point_light_2d.visible = true
		point_light_2d.color   = LIGHT_COLOR_AVAILABLE
		point_light_2d.energy  = LIGHT_ENERGY_AVAILABLE
		disabled               = false

	# ── OWNED BUT NOT MAXED ──────────────────────────────────
	elif skill_data.is_unlocked():
		self_modulate          = COLOR_UNLOCKED
		point_light_2d.visible = false
		disabled               = true

	# ── LOCKED ───────────────────────────────────────────────
	else:
		self_modulate          = COLOR_LOCKED
		if skill_data.locked_image != null:
			texture_normal = skill_data.locked_image
		point_light_2d.visible = false
		disabled               = true

	queue_redraw()


func _update_pulse() -> void:
	if skill_data.can_unlock() and not skill_data.is_on_max_level():
		var t     := Time.get_ticks_msec() / 1000.0
		var alpha := PULSE_MIN_ALPHA + (PULSE_MAX_ALPHA - PULSE_MIN_ALPHA) * (0.5 + 0.5 * sin(t * TAU / PULSE_PERIOD))
		self_modulate.a = alpha


func _process(_delta: float) -> void:
	update_visual()
	_update_pulse()


func _draw():
	if has_focus() and CommonGlobals.controller_support_on:
		draw_rect(
			Rect2(Vector2.ZERO, size),
			Color.WHITE,
			false,
			4.0
		)
		draw_rect(
			Rect2(Vector2(6, 6), size - Vector2(12, 12)),
			Color.WHITE,
			false,
			2.0
		)


func _on_mouse_entered() -> void:
	label.pivot_offset = label.size / 2
	create_tween().tween_property(label, "scale", LABEL_SCALE_HOVER, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_mouse_exited() -> void:
	create_tween().tween_property(label, "scale", LABEL_SCALE_NORMAL, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_pressed() -> void:
	print("pressed")
	SoundManager.play_sound_by_id(SoundManager.Sound.SKILL_PICKUP)
	skill_data.unlock()
