#version 450

layout (location=0) in ivec3 position;
layout (location=1) in int face_id;
layout (location=2) in int voxel_id;
layout (location=3) in ivec3 normal;

uniform mat4 viewproj;
uniform mat4 model;

out vec3 frag_pos;
out vec3 frag_normal;
flat out int vid;

void main() {
	gl_Position = viewproj * model * vec4(position, 1.0);
	frag_pos = vec3(model * vec4(position, 1.0));
	frag_normal = normal;
	vid = voxel_id;
}
