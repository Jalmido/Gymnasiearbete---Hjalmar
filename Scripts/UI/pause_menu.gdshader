shader_type canvas_item;

//Liten shader bakom paus menyn

uniform float blur_amount : hint_range(0, 5) = 2.0;
uniform float brightness : hint_range(0, 2) = 0.8;

//denna funktion hämtar pixlarna bakom ColorRect-noden
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    //färgen från skärmen bakom tas och blur appliceras
    vec4 color = textureLod(screen_texture, SCREEN_UV, blur_amount);

    //gör den också lite mörkare för att knapparna ska synas bättre
    color.rgb *= brightness;

    COLOR = color;
}