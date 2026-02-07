shader_type canvas_item;

uniform float blur_amount : hint_range(0, 5) = 2.0;
uniform float brightness : hint_range(0, 2) = 0.8;

// Denna funktion hämtar pixlarna bakom ColorRect-noden
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Vi hämtar färgen från skärmen bakom och applicerar blur (LOD)
    vec4 color = textureLod(screen_texture, SCREEN_UV, blur_amount);

    // Vi gör den också lite mörkare för att knapparna ska synas bättre
    color.rgb *= brightness;

    COLOR = color;
}