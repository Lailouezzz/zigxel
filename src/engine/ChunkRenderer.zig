const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm");

const Self = @This();

const Scene = @import("Scene.zig");
const ShaderProgram = @import("ShaderProgram.zig");
const UniformMap = @import("uniformMap.zig").UniformMap(&[_][:0]const u8{
	"viewproj",
	"model",
});

shaderProgram: ShaderProgram,
uniformMap: UniformMap,

pub fn init() !Self {
	const shaderProgram = try ShaderProgram.init(&[_]ShaderProgram.ShaderData{
	.{
		.source = @embedFile("shader/chunk.vert"),
		.shaderType = gl.VERTEX_SHADER,
	},
	.{
		.source = @embedFile("shader/chunk.frag"),
		.shaderType = gl.FRAGMENT_SHADER,
	},});

	return Self {
		.shaderProgram = shaderProgram,
		.uniformMap = try UniformMap.init(shaderProgram),
	};
}

pub fn render(self: Self, scene: Scene) void {
	gl.enable(gl.DEPTH_TEST);
	const viewproj = scene.camera.lookMatrix().mul(scene.projection);
	self.shaderProgram.bind();
	gl.uniformMatrix4fv(self.uniformMap.getUniform("viewproj"), 1, gl.FALSE, @ptrCast(&viewproj.fields));
	var it = scene.terrain.chunks.valueIterator();
	while (it.next()) |chunkColumn| {
		for (chunkColumn.*.*) |chunk| {
			if (chunk.verticesCount == 0) continue ;
			const model = chunk.modelMatrix();
			gl.uniformMatrix4fv(self.uniformMap.getUniform("model"), 1, gl.FALSE, @ptrCast(&model.fields));
			gl.bindVertexArray(chunk.vao);
			gl.drawArrays(gl.TRIANGLES, 0, @intCast(chunk.verticesCount));
		}
	}
	gl.bindVertexArray(0);
	self.shaderProgram.unbind();
}

pub fn deinit(self: *Self) void {
	self.uniformMap.deinit();
	self.shaderProgram.deinit();
}
