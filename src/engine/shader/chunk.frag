#version 450

out vec4 frag_out;

in vec3 frag_pos;
in vec3 frag_normal;
flat in int vid;

void main() {
	const vec3 ambient_light_dir = -normalize(vec3(-1, -1, -1));
	float diff = max(dot(frag_normal, ambient_light_dir), 0.0) * 0.1;
	frag_out = vec4(vec3(1) * diff + vec3(vid) / 256, 1);
}
