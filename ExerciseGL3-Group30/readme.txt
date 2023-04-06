Task GL3.1.1: Sampling a texture
	- The texture color was sampled based on the given UV coordinates, and the color factor was applied accordingly. 
	- The output color was set while preserving the alpha channel from the sampled texture.

	- No issues encountered	



Task GL3.1.2: UV coordinates and wrapping modes
	-  The vertex_tex_coords were modified to repeat the texture four times instead of once.
	- The floor texture's wrapping mode was set in tex_load_options.

	- No issues encountered



Task GL3.2.1: Projection matrix for a cube camera
	- The init_capture function in env_capture.js was completed by defining fovy, aspect, near, and far.
	- The mat4.perspective function was implemented using the defined variables to generate the projection matrix for the camera.

	- No issues encountered
 


Task GL3.2.2: Up vectors for cube camera
	- The vectors of CUBE_FACE_UP were modified to properly orient the camera.

	- No issues encountered



Task GL3.2.3: Reflection shader
	- View-space normals and viewing direction were passed from the vertex shader to the fragment shader.
	- The normal was transformed to camera coordinates, and the view vector was computed.
	- The surface normal and view vector were normalized, the reflected ray direction was computed, and the environment map was sampled using the reflected direction.

	- No issues encountered



Task GL3.3.1: Phong Lighting Shader with Shadows
	- The normal, light direction, and direction to camera were normalized.
	- The diffuse and specular components were computed.
	- The distance to the light was calculated.
	- A variable for attenuation was created.
	- Occlusion was checked using the shadow map, and tolerance was applied to avoid shadow acne.
	- The ambient component was applied, and the final color was computed.

	- A '-' was initially omitted in light_direction, causing the shadow render to be inverted. After revising the code, the mistake was found.

	- The tolerance was increased from 1.01 to 1.02 to prevent shadow acne.



Task GL3.3.2 Blend Options
	- The blend was added following the instructions provided in the homework.


	- No issues encountered.



CONTRIBUTIONS:
Antonio Jimenez (314363): 1/3
Theo Abel (312107): 1/3
Jules Perrin (316555): 1/3