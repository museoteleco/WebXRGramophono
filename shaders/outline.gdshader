shader_type spatial;
render_mode unshaded, blend_mix;

uniform float shell_thickness = 0.002;
uniform vec4 shell_color : source_color = vec4(0.85098, 0.533333, 0.478431, 0.2);

uniform float glow_speed = 3.0;
uniform float glow_min = 0.7;
uniform float glow_max = 1.0;

void vertex() {
    VERTEX += normalize(NORMAL) * shell_thickness;
}

void fragment() {
    // Smooth pulse between 0–1
    float pulse = (sin(TIME * glow_speed) + 1.0) * 0.5;

    // Remap pulse to desired range
    float glow = mix(glow_min, glow_max, pulse);

    ALBEDO = shell_color.rgb * glow;
    ALPHA = shell_color.a * glow;
}
