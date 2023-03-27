precision mediump float;
		
/* #TODO GL2.2.1
	Pass the normal to the fragment shader. 
	Create a vertex-to-fragment variable.
*/
varying vec3 v_normal;

void main()
{
	/* #TODO GL2.2.1
	Visualize the normals as false color. 
	*/
	
	// set the color from normals
	vec3 color =  v_normal * 0.5 + 0.5;

	gl_FragColor = vec4(color, 1.); // output: RGBA in 0..1 range
}
