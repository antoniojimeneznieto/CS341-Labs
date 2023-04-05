precision highp float;

varying vec3 v2f_normal;
varying vec3 v2f_vertex_position;
varying vec2 v2f_uv;


uniform vec3 light_position; // light position in camera coordinates
uniform vec3 light_color;
uniform samplerCube cube_shadowmap;
uniform sampler2D tex_color;

void main() {

	float material_shininess = 12.;

	float m_a = 0.1;

	/* #TODO GL3.1.1
	Sample texture tex_color at UV coordinates and display the resulting color.
	*/
	vec3 material_color = texture2D(tex_color, v2f_uv).rgb;
	
	/*
	#TODO GL3.3.1: Blinn-Phong with shadows and attenuation

	Compute this light's diffuse and specular contributions.
	You should be able to copy your phong lighting code from GL2 mostly as-is,
	though notice that the light and view vectors need to be computed from scratch here; 
	this time, they are not passed from the vertex shader. 
	Also, the light/material colors have changed; see the Phong lighting equation in the handout if you need
	a refresher to understand how to incorporate `light_color` (the diffuse and specular
	colors of the light), `v2f_diffuse_color` and `v2f_specular_color`.
	
	To model the attenuation of a point light, you should scale the light
	color by the inverse distance squared to the point being lit.
	
	The light should only contribute to this fragment if the fragment is not occluded
	by another object in the scene. You need to check this by comparing the distance
	from the fragment to the light against the distance recorded for this
	light ray in the shadow map.
	
	To prevent "shadow acne" and minimize aliasing issues, we need a rather large
	tolerance on the distance comparison. It's recommended to use a *multiplicative*
	instead of additive tolerance: compare the fragment's distance to 1.01x the
	distance from the shadow map.

	Implement the Blinn-Phong shading model by using the passed
	variables and write the resulting color to `color`.

	Make sure to normalize values which may have been affected by interpolation!
	*/

    // Normal, light direction and direction to the camera
    vec3 normal = normalize(v2f_normal);
    vec3 light_direction = normalize(light_position - v2f_vertex_position);
    vec3 direction_to_camera = normalize(-v2f_vertex_position);

    // Diffuse component
    float diffuse = max(0.0, dot(normal, light_direction));
    vec3 diffuse_color = diffuse * material_color * light_color;

    // Specular component
    vec3 half_vector = normalize(light_direction + direction_to_camera);
    float specular = pow(max(0.0, dot(normal, half_vector)), material_shininess);
    vec3 specular_color = specular * material_color * light_color; // Specular color should be white

    // Distance to the light
    float distance_to_light = length(light_position - v2f_vertex_position);

	// Attenuation
    float attenuation = 1.0 / (distance_to_light * distance_to_light);

    // Check for occlusion using the shadow map and apply a multiplicative tolerance
    float distance_from_shadowmap = textureCube(cube_shadowmap, -light_direction).r;
    float tolerance = 1.02; // 1.02 and not 1.01 to prevent shadow acnee

    // Calculate the final color
    vec3 color = material_color * m_a; // Ambient component
    if (length(v2f_vertex_position - light_position) < distance_from_shadowmap * tolerance) {
        color += (diffuse_color + specular_color) * attenuation;
    }

    gl_FragColor = vec4(color, 1.0); // Output: RGBA in 0..1 range
}