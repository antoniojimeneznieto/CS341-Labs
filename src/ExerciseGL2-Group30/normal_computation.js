
import * as vec3 from "../lib/gl-matrix_3.3.0/esm/vec3.js"

function get_vert(mesh, vert_id) {
	const offset = vert_id*3
	return  mesh.vertex_positions.slice(offset, offset+3)
}

function compute_triangle_normals_and_angle_weights(mesh) {

	/** #TODO GL2.1.1: 
	- compute the normal vector to each triangle in the mesh
	- push it into the array `tri_normals`
	- compute the angle weights for vert1, vert2, then vert3 and store it into an array [w1, w2, w3]
	- push this array into `angle_weights`

	Hint: you can use `vec3` specific methods such as `normalize()`, `add()`, `cross()`, `angle()`, or `subtract()`.
		  The absolute value of a float is given by `Math.abs()`.
	*/

	const num_faces     = (mesh.faces.length / 3) | 0
	const tri_normals   = []
	const angle_weights = []
	for(let i_face = 0; i_face < num_faces; i_face++) {
		const vert1 = get_vert(mesh, mesh.faces[3*i_face + 0])
		const vert2 = get_vert(mesh, mesh.faces[3*i_face + 1])
		const vert3 = get_vert(mesh, mesh.faces[3*i_face + 2])

		const edge12 = vec3.subtract(vec3.create(), vert2, vert1)
		const edge23 = vec3.subtract(vec3.create(), vert3, vert2)
		const edge31 = vec3.subtract(vec3.create(), vert1, vert3)
		
		// Modify the way triangle normals and angle_weights are computed
		const normal = vec3.create()
		vec3.cross(normal, edge12, edge23)
		vec3.normalize(normal, normal)

		const angle1 = vec3.angle(edge12, edge31)
		const angle2 = vec3.angle(edge23, edge12)
		const angle3 = vec3.angle(edge31, edge23)

		// Add your code for computing the angle weights
		const weight1 = Math.abs(angle1) / Math.PI
		const weight2 = Math.abs(angle2) / Math.PI
		const weight3 = Math.abs(angle3) / Math.PI

		tri_normals.push(normal)
		angle_weights.push([weight1, weight2, weight3])
		
	}
	return [tri_normals, angle_weights]
}

function compute_vertex_normals(mesh, tri_normals, angle_weights) {

	/** #TODO GL2.1.2: 
	- go through the triangles in the mesh
	- add the contribution of the current triangle to its vertices' normal
	- normalize the obtained vertex normals
	*/

	const num_faces    = (mesh.faces.length / 3) | 0
	const num_vertices = (mesh.vertex_positions.length / 3) | 0
	const vertex_normals = Array.from({ length: num_vertices }, () => [0., 0., 0.])

	for(let i_face = 0; i_face < num_faces; i_face++) {
		const iv1 = mesh.faces[3*i_face + 0]
		const iv2 = mesh.faces[3*i_face + 1]
		const iv3 = mesh.faces[3*i_face + 2]

		const normal = tri_normals[i_face]

		// Add your code for adding the contribution of the current triangle to its vertices' normals
		vec3.add(vertex_normals[iv1], vertex_normals[iv1], vec3.scale(vec3.create(), normal, angle_weights[i_face][0]))
		vec3.add(vertex_normals[iv2], vertex_normals[iv2], vec3.scale(vec3.create(), normal, angle_weights[i_face][1]))
		vec3.add(vertex_normals[iv3], vertex_normals[iv3], vec3.scale(vec3.create(), normal, angle_weights[i_face][2]))

	}

	for(let i_vertex = 0; i_vertex < num_vertices; i_vertex++) {
		// Normalize the vertices
		vec3.normalize(vertex_normals[i_vertex], vertex_normals[i_vertex])
	}

	return vertex_normals
}

export function mesh_preprocess(regl, mesh) {
	const [tri_normals, angle_weights] = compute_triangle_normals_and_angle_weights(mesh)
			
	const vertex_normals = compute_vertex_normals(mesh, tri_normals, angle_weights)

	mesh.vertex_positions = regl.buffer({data: mesh.vertex_positions, type: 'float32'})
	mesh.vertex_normals = regl.buffer({data: vertex_normals, type: 'float32'})
	mesh.faces = regl.elements({data: mesh.faces, type: 'uint16'})

	return mesh
}
