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
		.source = @embedFile("shader/vertex.shad"),
		.shaderType = gl.VERTEX_SHADER,
	},
	.{
		.source = @embedFile("shader/frag.shad"),
		.shaderType = gl.FRAGMENT_SHADER,
	},});

	return Self {
		.shaderProgram = shaderProgram,
		.uniformMap = try UniformMap.init(shaderProgram),
	};
}

pub fn render(self: Self, scene: Scene) void {
	// _ = self;
	// _ = scene;
	const viewproj = scene.camera.lookMatrix().mul(scene.projection);
	self.shaderProgram.bind();
	gl.uniformMatrix4fv(self.uniformMap.getUniform("viewproj"), 1, gl.FALSE, @ptrCast(&viewproj.fields));
	for (0..8) |x| {
		for (0..8) |y| {
			const currentChunk = scene.terrain.chunk[x][y];
			const model = currentChunk.modelMatrix();
			gl.uniformMatrix4fv(self.uniformMap.getUniform("model"), 1, gl.FALSE, @ptrCast(&model.fields));
			gl.bindVertexArray(currentChunk.vao);
			gl.drawArrays(gl.TRIANGLES, 0, @intCast(currentChunk.verticesCount));
		}
	}
	gl.bindVertexArray(0);
	self.shaderProgram.unbind();
}

pub fn deinit(self: *Self) void {
	self.uniformMap.deinit();
	self.shaderProgram.deinit();
}
