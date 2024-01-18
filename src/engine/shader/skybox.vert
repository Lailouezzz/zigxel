#version 450

layout (location=0) in ivec3 position;

uniform mat4 rot_mat;

out float yPos;

void main() {
	gl_Position = rot_mat * vec4(position, 1.0);
	yPos = position.y;
}
