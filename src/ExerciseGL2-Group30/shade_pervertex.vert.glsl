// Vertex attributes, specified in the "attributes" entry of the pipeline
attribute vec3 vertex_position;
attribute vec3 vertex_normal;

// Per-vertex outputs passed on to the fragment shader
/* #TODO GL2.3
	Pass the values needed for per-pixel
	Create a vertex-to-fragment variable.
*/
varying vec3 v2f_color;

// Global variables specified in "uniforms" entry of the pipeline
uniform mat4 mat_mvp;
uniform mat4 mat_model_view;
uniform mat3 mat_normals_to_view;

uniform vec3 light_position; //in camera space coordinates already

uniform vec3 material_color;
uniform float material_shininess;
uniform vec3 light_color;

void main() {
	float material_ambient = 0.1;

	/** #TODO GL2.3 Gouraud lighting
	Compute the visible object color based on the Blinn-Phong formula.

	Hint: Compute the vertex position, normal and light_position in eye space.
	Hint: Write the final vertex position to gl_Position
	*/
	vec4 vertex_position_view = mat_model_view * vec4(vertex_position, 1.0);
	vec3 vertex_normal_view = normalize(mat_normals_to_view * vertex_normal);

	vec3 N = vertex_normal_view;
	vec3 L = normalize(light_position - vertex_position_view.xyz);
	vec3 V = -normalize(vertex_position_view.xyz);
	vec3 H = normalize(L + V);

	float diffuse = max(dot(N, L), 0.0);
	float specular = 0.0;
	if (diffuse > 0.0) {
		specular = pow(max(dot(N, H), 0.0), material_shininess);
	}

	v2f_color = (material_ambient * material_color + diffuse * material_color) * light_color + specular * material_color * light_color;

	gl_Position = mat_mvp * vec4(vertex_position, 1);
}
