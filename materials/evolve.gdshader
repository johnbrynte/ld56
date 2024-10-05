//2D Heat Wave Effect Shader by marsonfire
//Feel free to modify this shader in anyway and to use this for anything you want 
//This was made by someone learning Shaders, so lots of comments and stuff to help me know what's going on...

//1. Add a Sprite2D
//2. Add a noise texture to that Sprite2D - resize as desired
//3. Check the "Seamless" box
//4. Set the CanvasItem -> Texture -> Repeat to "Enabled"
//5. Apply the shader to the CanvasItem -> Material -> NewShaderMaterial (You can also drag and drop the shader onto the material)
//6. Play with parameters for desired effects

shader_type canvas_item;

//Get the screen texture
uniform sampler2D screenTexture : hint_screen_texture;

//How much distortion is desired? - default = 0.01
uniform float multiplierAmount : hint_range(0.0, 0.1) = 0.01;

uniform float opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 color = texture(TEXTURE, (vec2(1.0, 1.0) + multiplierAmount * vec2(cos(TIME * 2.0 + 20.0 * UV.x), 1.0 + sin(TIME * 2.0 + 20.0 * UV.y))) * UV);
	COLOR = vec4(color.xyz, color.w * opacity);
}