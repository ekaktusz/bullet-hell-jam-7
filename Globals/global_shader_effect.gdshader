shader_type canvas_item;

uniform float radius : hint_range(0.0, 2.0) = 0.8;
uniform float softness : hint_range(0.001, 1.0) = 0.3;
uniform float strength : hint_range(0.0, 1.0) = 0.5;

uniform float ellipse_x : hint_range(0.1, 3.0) = 1.0;
uniform float ellipse_y : hint_range(0.1, 3.0) = 1.3;

uniform vec4 vignette_color : source_color =
    vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    vec2 uv = UV;

    vec2 centered = uv * 2.0 - 1.0;

    // Aspect ratio correction
    centered.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;

    // Ellipse scaling
    centered.x /= ellipse_x;
    centered.y /= ellipse_y;

    float dist = length(centered);

    float vignette =
        smoothstep(radius - softness, radius, dist);

    vec4 color = vignette_color;
    color.a *= vignette * strength;

    COLOR = color;
}