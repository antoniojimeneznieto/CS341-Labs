Task GL2.1.1: Compute triangle normals and opening angles
	- Successfully computed the normal vector of each triangle and the weights of each angle. Stored the data in the corresponding arrays.

	- No problems encountered, the instructions and the formulas were very clear and the hint was also very helpful. 

Task GL2.1.2: Compute vertex normals
	- Successfully added the contribution of each triangle to its vertices' normal.

	- No problems encountered.


Task GL2.2.1: Pass normals to fragment shader
	- Added a varying variable for the normal and updated the fragment shader to draw a false-color representation of normals using the given formula (normal * 0.5 + 0.5).

	- Initially, the same normal value was present everywhere. After referring to hints and clarifications provided in moodle, the issues were resolved.


Task GL2.2.2: Transforming the normals
	- Calculated and applied the transformation matrix to the normal vectors.

	- Issues were resolved using the hints and clarifications provided in moodle.



Task GL2.3: Gouraud lighting
	- Computed the lighting value for each vertex, applied the model-view matrix to the vertex position, and stored the color in a varying variable.

	- Encountered an issue with darker colours in some areas of the image. We think there must be an error applying the formulas. Unfortunately we could not spot it. 


Task GL2.4: Phong lighting
	- Set up the varying values (surface normal, view vector, light vector) and computed their values.
	- Implemented the Blinn-Phong formula using the computed values.

	- Encountered an issue with brighter colours. We think there must be an error on the formulas. Unfortunately, we could not spot the error.



CONTRIBUTIONS:
Antonio Jimenez (314363): 1/3
Theo Abel (312107): 1/3
Jules Perrin (316555): 1/3