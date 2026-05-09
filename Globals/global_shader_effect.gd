extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func set_vignette_radius(radius: float) -> void:
	color_rect.material.set_shader_parameter("radius", radius)
