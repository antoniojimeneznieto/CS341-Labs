precision highp float;

#define EPSILON 1e-12

#define MAX_RANGE 1e6
//#define NUM_REFLECTIONS

//#define NUM_SPHERES
#if NUM_SPHERES != 0
uniform vec4 spheres_center_radius[NUM_SPHERES]; // ...[i] = [center_x, center_y, center_z, radius]
#endif

//#define NUM_PLANES
#if NUM_PLANES != 0
uniform vec4 planes_normal_offset[NUM_PLANES]; // ...[i] = [nx, ny, nz, d] such that dot(vec3(nx, ny, nz), point_on_plane) = d
#endif

//#define NUM_CYLINDERS
struct Cylinder {
	vec3 center;
	vec3 axis;
	float radius;
	float height;
};
#if NUM_CYLINDERS != 0
uniform Cylinder cylinders[NUM_CYLINDERS];
#endif

//#define SHADING_STRATEGY_COLOR
//#define SHADING_STRATEGY_NORMALS

// materials
//#define NUM_MATERIALS
struct Material {
	vec3 color;
	float ambient;
	float diffuse;
	float specular;
	float shininess;
	float mirror;
};
uniform Material materials[NUM_MATERIALS];
#if (NUM_SPHERES != 0) || (NUM_PLANES != 0) || (NUM_CYLINDERS != 0)
uniform int object_material_id[NUM_SPHERES+NUM_PLANES+NUM_CYLINDERS];
#endif

/*
	Get the material corresponding to mat_id from the list of materials.
*/
Material get_material(int mat_id) {
	Material m = materials[0];
	for(int mi = 1; mi < NUM_MATERIALS; mi++) {
		if(mi == mat_id) {
			m = materials[mi];
		}
	}
	return m;
}

// lights
//#define NUM_LIGHTS
struct Light {
	vec3 color;
	vec3 position;
};
#if NUM_LIGHTS != 0
uniform Light lights[NUM_LIGHTS];
#endif
uniform vec3 light_color_ambient;


varying vec3 v2f_ray_origin;
varying vec3 v2f_ray_direction;

/*
	Solve the quadratic a*x^2 + b*x + c = 0. The method returns the number of solutions and store them
	in the argument solutions.
*/
int solve_quadratic(float a, float b, float c, out vec2 solutions) {

	// Linear case: bx+c = 0
	if (abs(a) < 1e-12) {
		if (abs(b) < 1e-12) {
			// no solutions
			return 0; 
		} else {
			// 1 solution: -c/b
			solutions[0] = - c / b;
			return 1;
		}
	} else {
		float delta = b * b - 4. * a * c;

		if (delta < 0.) {
			// no solutions in real numbers, sqrt(delta) produces an imaginary value
			return 0;
		} 

		// Avoid cancellation:
		// One solution doesn't suffer cancellation:
		//      a * x1 = 1 / 2 [-b - bSign * sqrt(b^2 - 4ac)]
		// "x2" can be found from the fact:
		//      a * x1 * x2 = c

		// We do not use the sign function, because it returns 0
		// float a_x1 = -0.5 * (b + sqrt(delta) * sign(b));
		float sqd = sqrt(delta);
		if (b < 0.) {
			sqd = -sqd;
		}
		float a_x1 = -0.5 * (b + sqd);


		solutions[0] = a_x1 / a;
		solutions[1] = c / a_x1;

		// 2 solutions
		return 2;
	} 
}

/*
	Check for intersection of the ray with a given sphere in the scene.
*/
bool ray_sphere_intersection(
		vec3 ray_origin, vec3 ray_direction, 
		vec3 sphere_center, float sphere_radius, 
		out float t, out vec3 normal) 
{
	vec3 oc = ray_origin - sphere_center;

	vec2 solutions; // solutions will be stored here

	int num_solutions = solve_quadratic(
		// A: t^2 * ||d||^2 = dot(ray_direction, ray_direction) but ray_direction is normalized
		1., 
		// B: t * (2d dot (o - c))
		2. * dot(ray_direction, oc),	
		// C: ||o-c||^2 - r^2				
		dot(oc, oc) - sphere_radius*sphere_radius,
		// where to store solutions
		solutions
	);

	// result = distance to collision
	// MAX_RANGE means there is no collision found
	t = MAX_RANGE+10.;
	bool collision_happened = false;

	if (num_solutions >= 1 && solutions[0] > 0.) {
		t = solutions[0];
	}
	
	if (num_solutions >= 2 && solutions[1] > 0. && solutions[1] < t) {
		t = solutions[1];
	}

	if (t < MAX_RANGE) {
		vec3 intersection_point = ray_origin + ray_direction * t;
		normal = (intersection_point - sphere_center) / sphere_radius;

		return true;
	} else {
		return false;
	}	
}


/*
	Check for intersection of the ray with a given plane in the scene.
*/
bool ray_plane_intersection(
		vec3 ray_origin, vec3 ray_direction, 
		vec3 plane_normal, float plane_offset, 
		out float t, out vec3 normal) 
{
	// Normalize the vectors
	plane_normal = normalize(plane_normal);
	ray_direction = normalize(ray_direction);

	// If ray is parallel to the plane, there is no intersection
    float denom = dot(ray_direction, plane_normal);
    if (abs(denom) < EPSILON) {
        return false;
    }
	
	// Compute the distance along the ray to the intersection point
    t = (plane_offset - dot(ray_origin, plane_normal)) / denom;

	// If the intersection is behind the viewer or too far away return false
    if (t < 0. || t > MAX_RANGE) {
        return false;
    }

	// If we are viewing the back face of the plane, we flip the normal
	if (dot(plane_normal, ray_direction) > 0.) {
		normal = -plane_normal;
	} else {
		normal = plane_normal;
	}

	return true;

	/* NOT NEEDED BUT THEY MAY BE INTERESTING IN THE FUTURE:
		vec3 intersection_point = ray_origin + t * ray_direction;
		vec3 plane_center = plane_normal * plane_offset; 
	*/
}

/*
	Check for intersection of the ray with a given cylinder in the scene.
*/
bool ray_cylinder_intersection(
		vec3 ray_origin, vec3 ray_direction, 
		Cylinder cyl,
		out float t, out vec3 normal) 
{
	vec3 center = cyl.center;
	vec3 axis = normalize(cyl.axis);
	float radius = cyl.radius;
	float height = cyl.height;
	vec3 OC = ray_origin - center;

	/* Check theory.pdf to understand the derivation of the quadratic formula */
	float a = dot(ray_direction - axis * dot(ray_direction, axis), ray_direction - axis * dot(ray_direction, axis));
	float b = 2. * dot(ray_direction - axis * dot(ray_direction, axis), OC - axis * dot(OC, axis));
	float c = dot(OC - axis * dot(OC, axis), OC - axis * dot(OC, axis)) - radius * radius;

	// Solve quadratic equation to get intersection candidates
	vec2 solutions;
	int num_solutions = solve_quadratic(a, b, c, solutions);

	bool collision_happened = false;
	vec3 intersection_point;
	vec3 intersection_normal;
	float min_t = MAX_RANGE + 10.;

	// Check intersection candidates to find the first valid one
	for (int i = 0; i < 2; i++) {
		float candidate_t = solutions[i];
		vec3 candidate_point = ray_origin + ray_direction * candidate_t;

		// check if candidate point is within cylinder height
		float z = dot(candidate_point - center, axis);
		if (z < -0.5 * height || z > 0.5 * height) {
			continue;
		}

		// Update t
		if (candidate_t > EPSILON && candidate_t < min_t) {
			collision_happened = true;
			min_t = candidate_t;
			intersection_point = candidate_point;

			intersection_normal = normalize(candidate_point - center - z * axis);

			// Orient the normal towards the viewer
            if (dot(ray_direction, intersection_normal) > 0.) {
                intersection_normal = -intersection_normal;
            }
		}
	}

	// Set output variables and return result
	if (collision_happened) {
		t = min_t;
		normal = intersection_normal;
		return true;
	} 

	return false;
}


/*
	Check for intersection of the ray with any object in the scene.
*/
bool ray_intersection(
		vec3 ray_origin, vec3 ray_direction, 
		out float col_distance, out vec3 col_normal, out int material_id) 
{
	col_distance = MAX_RANGE + 10.;
	col_normal = vec3(0., 0., 0.);

	float object_distance;
	vec3 object_normal;

	// Check for intersection with each sphere
	#if NUM_SPHERES != 0 // only run if there are spheres in the scene
	for(int i = 0; i < NUM_SPHERES; i++) {
		bool b_col = ray_sphere_intersection(
			ray_origin, 
			ray_direction, 
			spheres_center_radius[i].xyz, 
			spheres_center_radius[i][3], 
			object_distance, 
			object_normal
		);

		// choose this collision if its closer than the previous one
		if (b_col && object_distance < col_distance) {
			col_distance = object_distance;
			col_normal = object_normal;
			material_id =  object_material_id[i];
		}
	}
	#endif

	// Check for intersection with each plane
	#if NUM_PLANES != 0 // only run if there are planes in the scene
	for(int i = 0; i < NUM_PLANES; i++) {
		bool b_col = ray_plane_intersection(
			ray_origin, 
			ray_direction, 
			planes_normal_offset[i].xyz, 
			planes_normal_offset[i][3], 
			object_distance, 
			object_normal
		);

		// choose this collision if its closer than the previous one
		if (b_col && object_distance < col_distance) {
			col_distance = object_distance;
			col_normal = object_normal;
			material_id =  object_material_id[NUM_SPHERES+i];
		}
	}
	#endif

	// Check for intersection with each cylinder
	#if NUM_CYLINDERS != 0 // only run if there are cylinders in the scene
	for(int i = 0; i < NUM_CYLINDERS; i++) {
		bool b_col = ray_cylinder_intersection(
			ray_origin, 
			ray_direction,
			cylinders[i], 
			object_distance, 
			object_normal
		);

		// choose this collision if its closer than the previous one
		if (b_col && object_distance < col_distance) {
			col_distance = object_distance;
			col_normal = object_normal;
			material_id =  object_material_id[NUM_SPHERES+NUM_PLANES+i];
		}
	}
	#endif

	return col_distance < MAX_RANGE;
}

/*
	Return the color at an intersection point given a light and a material, exluding the contribution
	of potential reflected rays.
*/
vec3 lighting(
		vec3 object_point, vec3 object_normal, vec3 direction_to_camera, 
		Light light, Material mat) {

	return mat.color;
}

/*
Render the light in the scene using ray-tracing!
*/
vec3 render_light(vec3 ray_origin, vec3 ray_direction) {

	vec3 pix_color = vec3(0.);

	float col_distance;
	vec3 col_normal = vec3(0.);
	int mat_id = 0;
	if(ray_intersection(ray_origin, ray_direction, col_distance, col_normal, mat_id)) {
		Material m = get_material(mat_id);
		pix_color = m.color;
	}

	return pix_color;
}


/*
	Draws the normal vectors of the scene in false color.
*/
vec3 render_normals(vec3 ray_origin, vec3 ray_direction) {
	float col_distance;
	vec3 col_normal = vec3(0.);
	int mat_id = 0;

	if( ray_intersection(ray_origin, ray_direction, col_distance, col_normal, mat_id) ) {	
		return 0.5*(col_normal + 1.0);
	} else {
		vec3 background_color = vec3(0., 0., 1.);
		return background_color;
	}
}


void main() {
	vec3 ray_origin = v2f_ray_origin;
	vec3 ray_direction = normalize(v2f_ray_direction);

	vec3 pix_color = vec3(0.);

	#ifdef SHADING_STRATEGY_NORMALS
	pix_color = render_normals(ray_origin, ray_direction);
	#endif

	#ifdef SHADING_STRATEGY_COLOR
	pix_color = render_light(ray_origin, ray_direction);
	#endif

	gl_FragColor = vec4(pix_color, 1.);
}
