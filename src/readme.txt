Task RT2.1: Implement Lighting Models
	- We have utilized the lighting formulas taught in our classes to compute the diffuse and specular components of the lighting function. 
	- Depending on the shading mode (i.e Blinn-Phong), we have followed and translated the formulas to compute the total intensity from all the lights.
	
	- We encountered a problem due to an incorrect formulation of the diffuse formula, leading to an unsatisfactory result. Fortunately, a double check enabled us to rectify the issue.

Task RT2.2: Implement shadows
	- we have generated a shadow ray from the intersection point to the light. If this ray intersects with an object, we have updated the diffuse and specular components correspondingly. 
	- To eliminate the issue of acne, we have applied a defined constant of the order 1e-3 in the intersection functions. 
	
	- Despite some initial uncertainty about resolving the acne problem, referring to the lectures and forum helped us to overcome it.

Task RT2.3.2: Implement reflections
	- We followed the reflection formulas provided in the slides and made appropriate adaptations to avoid recursion. 
	- The screenshots of mirrors have both reflections: 2

	- We initially forgot to incorporate the (1. - m.mirror factor), which led to incorrect results.


CONTRIBUTIONS:
Antonio Jimenez (314363): 1/3
Theo Abel (312107): 1/3
Jules Perrin (316555): 1/3

