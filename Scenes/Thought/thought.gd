extends Node2D

@onready var label: Label = $Label

var is_good = true

var good_thoughts = [
	"Nice butt, gorgeous!",
	"5 day streak. Nice.",
	"I deserve something nice",
	"Okay, that was smooth",
	"Fake it 'til you make it",
	"Man, I'm funny!",
	"Wow, they adore me!",
	"Smiled at a stranger. Check.",
	"Bitch, I'm fabulous",
	"Snack time",
	"I'm grateful for my mom",
	"I'm grateful for my dad",
	"I'm grateful for this awesome pizza",
	"Who's a fart-for-brains now, Kyle from second-grade?",
	"I love my friends",
	"My tomato soup kicks ass",
	"That sock is ridiculous. I love it.",
	"I'm gonna talk about it",
	"I will ask them out!",
	"I smell good",
	"I'm goning to do it!",
	"I'm lucky to have friends like them"
]
var bad_thoughts = ["I'm fat",
	"I can't do this forever",
	"I'm not good enough",
	"Everyone is getting married, why am I still single?",
	"I'm too scared to talk about this",
	"My thumbs look weird",
	"I feel itchy. Is it chlamydia?",
	"My forehead is huge",
	"My forehead is a five-head",
	"I should've said something",
	"I'm so awkward",
	"I'm so lazy",
	"I should've stayed quiet",
	"My friends hate me",
	"I look like a potato",
	"I'm so alone",
	"I'm so dumb",
	"My boss thinks I'm lazy",
	"Why bother?",
	"I'm a fraud",
	"My mom thinks I'm stupid",
	"My dad thinks I'm a loser",
	"I can't finish anything",
	"I'm weak",
	"They're not going to call me back",
	"They're so much younger, and achieved so much more thane me",
	"I'm too old for this",
	"That was so embarrassing!",
	"Therapy is so expensive...",
	"I can't stand myself",
	"They probably will say no, anyways",
	"My Mom loves my brother more than me",
	"Scroll more",
	"I don't deserve anything",
	"My ex is better off me",
	"I have no control over my life",
	"I don't feel like doing anything",
	"Hate them",
	"Everyone is so stupid",
	"I'm stupid",
	"I'm not capable",
	"That thing I did 12 years ago"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var value = randi_range(0, 2)
	if is_good:
		label.text = good_thoughts[value]
		label.add_theme_color_override("font_color", Color.CHARTREUSE)
	else:
		label.text = bad_thoughts[value]
		label.add_theme_color_override("font_color", Color.CRIMSON)

func remove():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
