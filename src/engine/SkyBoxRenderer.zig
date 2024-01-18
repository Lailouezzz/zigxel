const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm");

const Self = @This();

const Scene = @import("Scene.zig");
const ShaderProgram = @import("ShaderProgram.zig");
const UniformMap = @import("uniformMap.zig").UniformMap(&[_][:0]const u8{
	"rot_mat",
});

shaderProgram: ShaderProgram,
uniformMap: UniformMap,
boxVbo: gl.GLuint,
vao: gl.GLuint,

pub fn init() !Self {
	var vao: gl.GLuint = undefined;

	gl.createVertexArrays(1, &vao);
	gl.createVertexArrays(1, &vao);
	errdefer gl.deleteVertexArrays(1, &vao);
	gl.bindVertexArray(vao);

	var vbo: gl.GLuint = undefined;
	gl.createBuffers(1, &vbo);
	errdefer gl.deleteBuffers(1, &vbo);
	gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
	var vertices = [_]i8{
	-1.0,-1.0,-1.0,
	-1.0,-1.0, 1.0,
	-1.0, 1.0, 1.0,
	1.0, 1.0,-1.0,
	-1.0,-1.0,-1.0,
	-1.0, 1.0,-1.0,
	1.0,-1.0, 1.0,
	-1.0,-1.0,-1.0,
	1.0,-1.0,-1.0,
	1.0, 1.0,-1.0,
	1.0,-1.0,-1.0,
	-1.0,-1.0,-1.0,
	-1.0,-1.0,-1.0,
	-1.0, 1.0, 1.0,
	-1.0, 1.0,-1.0,
	1.0,-1.0, 1.0,
	-1.0,-1.0, 1.0,
	-1.0,-1.0,-1.0,
	-1.0, 1.0, 1.0,
	-1.0,-1.0, 1.0,
	1.0,-1.0, 1.0,
	1.0, 1.0, 1.0,
	1.0,-1.0,-1.0,
	1.0, 1.0,-1.0,
	1.0,-1.0,-1.0,
	1.0, 1.0, 1.0,
	1.0,-1.0, 1.0,
	1.0, 1.0, 1.0,
	1.0, 1.0,-1.0,
	-1.0, 1.0,-1.0,
	1.0, 1.0, 1.0,
	-1.0, 1.0,-1.0,
	-1.0, 1.0, 1.0,
	1.0, 1.0, 1.0,
	-1.0, 1.0, 1.0,
	1.0,-1.0, 1.0
	};
	gl.bufferData(gl.ARRAY_BUFFER, vertices.len * @sizeOf(@TypeOf(vertices[0])), &vertices, gl.STATIC_DRAW);
	gl.enableVertexAttribArray(0);
	gl.vertexAttribIPointer(0, 3, gl.BYTE, 0, null);
	gl.bindBuffer(gl.ARRAY_BUFFER, 0);
	gl.bindVertexArray(0);
	const shaderProgram = try ShaderProgram.init(&[_]ShaderProgram.ShaderData{
	.{
		.source = @embedFile("shader/skybox.vert"),
		.shaderType = gl.VERTEX_SHADER,
	},
	.{
		.source = @embedFile("shader/skybox.frag"),
		.shaderType = gl.FRAGMENT_SHADER,
	},});

	return Self {
		.shaderProgram = shaderProgram,
		.uniformMap = try UniformMap.init(shaderProgram),
		.boxVbo = vbo,
		.vao = vao,
	};
}

pub fn render(self: Self, scene: Scene) void {
	gl.disable(gl.DEPTH_TEST);
	self.shaderProgram.bind();
	const rotMat = zlm.Mat4.createLook(zlm.vec3(0, 0, 0), scene.camera.dir, zlm.vec3(0, 1, 0)).mul(scene.projection);
	gl.uniformMatrix4fv(self.uniformMap.getUniform("rot_mat"), 1, gl.FALSE, @ptrCast(&rotMat.fields));
	gl.bindVertexArray(self.vao);
	gl.drawArrays(gl.TRIANGLES, 0, 12*3);
	gl.bindVertexArray(0);
	self.shaderProgram.unbind();
}

pub fn deinit(self: *Self) void {
	gl.deleteVertexArrays(1, &self.vao);
	gl.deleteBuffers(1, &self.boxVbo);
}
