precision mediump float;

/* #TODO GL3.2.3
	Setup the varying values needed to compue the Phong shader:
	* surface normal
	* view vector: direction to camera
*/
varying vec3 v2f_normal;
varying vec3 v2f_dir_to_camera;

uniform samplerCube cube_env_map;

void main()
{
	/*
	/* #TODO GL3.2.3: Mirror shader
	Calculate the reflected ray direction R and use it to sample the environment map.
	Pass the resulting color as output.
	*/

	// Normalize the surface normal and view vector
	vec3 normal = normalize(v2f_normal);
	vec3 view_vector = normalize(v2f_dir_to_camera);

	// Calculate the reflected ray direction R
	vec3 R = reflect(-view_vector, normal);

	// Sample the environment map using the reflected direction
	vec3 color = textureCube(cube_env_map, R).rgb;

	gl_FragColor = vec4(color, 1.); // output: RGBA in 0..1 range
}
