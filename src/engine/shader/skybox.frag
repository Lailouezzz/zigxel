#version 450

out vec4 frag_out;

in float yPos;

void main() {
	float y = (yPos + 1.0) / 2.0;
	vec3 bottomColor = vec3(0.9, 0.9, 0.9);
	vec3 topColor = vec3(0.3, 0.6, 0.85);
	frag_out = vec4(y * topColor + (1.0 - y) * bottomColor, 1.0);
}
