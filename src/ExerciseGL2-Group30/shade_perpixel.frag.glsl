precision mediump float;

/* #TODO GL2.4
	Setup the varying values needed to compue the Phong shader:
	* surface normal
	* lighting vector: direction to light
	* view vector: direction to camera
*/
varying vec3 v2f_normal;
varying vec3 v2f_dir_to_light;
varying vec3 v2f_dir_from_view;

uniform vec3 material_color;
uniform float material_shininess;
uniform vec3 light_color;

void main()
{
	float material_ambient = 0.1;

	/*
	/** #TODO GL2.4: Apply the Blinn-Phong lighting model

	Implement the Blinn-Phong shading model by using the passed
	variables and write the resulting color to `color`.

	Make sure to normalize values which may have been affected by interpolation!
	*/

	 // Normalize the varying values
    vec3 normal = normalize(v2f_normal);
    vec3 dir_to_light = normalize(v2f_dir_to_light);
    vec3 dir_from_view = normalize(v2f_dir_from_view);

	// Ambient lighting
    vec3 ambient = material_ambient * material_color;

	 // Diffuse lighting
    float diffuse_intensity = max(dot(normal, dir_to_light), 0.0);
    vec3 diffuse = diffuse_intensity * material_color;

	 // Specular lighting
    vec3 halfway_vector = normalize(dir_to_light + dir_from_view);
    float specular_intensity = pow(max(dot(normal, halfway_vector), 0.0), material_shininess);
    vec3 specular = specular_intensity * light_color;


	// Combine lighting components
    vec3 color = ambient + diffuse + specular;
	gl_FragColor = vec4(color, 1.); // output: RGBA in 0..1 range
}
