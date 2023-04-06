precision mediump float;
		
// Texture coordinates passed from vertex shader
varying vec2 v2f_uv;

// Texture to sample color from
uniform sampler2D tex_color;

uniform float color_factor;

void main()
{
	// Sample texture tex_color at UV coordinates
	vec4 sampledColor = texture2D(tex_color, v2f_uv);

	// Apply color_factor to the sampled color
	vec3 color = sampledColor.rgb * color_factor;

	// Set the output color, preserving the alpha channel from the sampled texture
	gl_FragColor = vec4(color, sampledColor.a);
}
