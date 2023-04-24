Task 2.1: 1D noise
	- The implemented function perlin_noise_1d() takes a float input "x" and evaluates the 1D Perlin noise function. 
	- The surrounding grid points of x are determined, their gradients are looked up, and the linear functions these gradients describe are evaluated. 
	- Finally, the values are interpolated using the smooth interpolation polynomial blending_weight_poly.
	
	- No issues encountered

Task 3.1: FBM 1D
	- The function perlin_fbm_1d() computes 1D fBm, which is the sum of num_octaves octaves of Perlin noise, starting at octave 0. 
	- The frequency and amplitude multipliers are used to rescale each successive octave.

	- No issues encountered

Task 4.1-4.3
	- Implemented the function perlin_noise() and perlin_fmb in the same way as in 2.1 and 3.1 but considering the vector instead of a point. 
	- The function turbulence() computes 2D turbulence by summing the absolute values of num_octaves octaves of Perlin noise, starting at octave 0. 
	- The frequency and amplitude multipliers are used to rescale each successive octave.

	- No issues encountered

Task 5.1
	- tex_map: Implements a map texture evaluation routine using the perlin_fbm routine and the terrain color constants. It returns a mix of terrain_color_grass and terrain_color_mountain based on the height value obtained from perlin_fbm().
	- tex_wood: Implements a wood texture evaluation routine using the 2D turbulence routine and the wood color constants. It calculates the radial distance from the point to the origin and interpolates between dark and light brown colors using the alpha value.
	- tex_marble: Implements a marble texture evaluation routine using the 2D fBm routine and the marble color constants. It calculates the alpha value and interpolates between the white color and the original point color using the alpha value.

	- No issues encountered

Task 6.1
	- Implemented terrain_build_mesh to take a height map and generate the terrain mesh with vertex positions, normals and faces.
	- Any point below the WATER_LEVEL constant is clamped back to WATER_LEVEL and the its normal is set to [0,0,1].
	- Triangulates the grid cell by adding two triangles to fill each square

	- The vertex shaders sets up the Blinn-Phong varying variables, computes the normal and the vertex position.
	- Fragment shaders computes the terrain color and shininess based on the height of the vertex and then applies the Blinn-Phong shading model as we did in previous weeks. 

	- No issues encountered

CONTRIBUTIONS:
Antonio Jimenez (314363): 1/3
Theo Abel (312107): 1/3
Jules Perrin (316555): 1/3



