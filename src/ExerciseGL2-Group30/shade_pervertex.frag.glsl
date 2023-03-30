precision mediump float;

// #TODO GL2 setup varying
varying vec3 v2f_color;

void main()
{
	/*
	#TODO GL2.3: Gouraud lighting
	*/
	vec3 color = v2f_color;
	gl_FragColor = vec4(color, 1.); // output: RGBA in 0..1 range
}
