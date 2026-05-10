shader_type canvas_item;

/*
    Trippy swirling background shader for Godot 4
    Works well with psychedelic / abstract painted textures.

    Recommended:
    - Put this on a ColorRect or TextureRect covering the screen
    - Use your current background texture
    - Enable Repeat on the texture import settings
*/

uniform sampler2D noise_tex : repeat_enable;

uniform float swirl_strength : hint_range(0.0, 2.0) = 0.35;
uniform float swirl_speed : hint_range(0.0, 5.0) = 0.8;

uniform float wave_strength : hint_range(0.0, 0.2) = 0.03;
uniform float wave_speed : hint_range(0.0, 5.0) = 1.2;

uniform float zoom : hint_range(0.1, 5.0) = 1.0;

uniform vec2 flow_direction = vec2(0.2, 0.05);

uniform float chromatic_aberration : hint_range(0.0, 0.02) = 0.004;

void fragment() {
    vec2 uv = UV;

    // Center coordinates
    vec2 p = uv - 0.5;

    // Distance from center
    float r = length(p);

    // Time
    float t = TIME * swirl_speed;

    // Swirl rotation
    float angle = swirl_strength * exp(-r * 2.0) * sin(r * 12.0 - t * 2.0);

    float s = sin(angle);
    float c = cos(angle);

    mat2 rot = mat2(
    vec2(c, -s),
    vec2(s, c)
);

    p = rot * p;

    // Wavy distortion
    p.x += sin(p.y * 15.0 + TIME * wave_speed) * wave_strength;
    p.y += cos(p.x * 15.0 - TIME * wave_speed * 0.8) * wave_strength;

    // Flow movement
    p += flow_direction * TIME * 0.03;

    // Zoom
    vec2 final_uv = p / zoom + 0.5;

    // Chromatic aberration offsets
    vec2 aberr = vec2(chromatic_aberration, 0.0);

    float r_col = texture(noise_tex, final_uv + aberr).r;
    float g_col = texture(noise_tex, final_uv).g;
    float b_col = texture(noise_tex, final_uv - aberr).b;

    vec3 color = vec3(r_col, g_col, b_col);

    // Extra psychedelic pulsing
    color *= 1.0 + 0.08 * sin(TIME * 2.0 + r * 20.0);

    COLOR = vec4(color, 1.0);
}