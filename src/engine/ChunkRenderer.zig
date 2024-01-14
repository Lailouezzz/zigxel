const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");

const Self = @This();

const Scene = @import("Scene.zig");
const ShaderProgram = @import("ShaderProgram.zig");
const UniformMap = @import("uniformMap.zig").UniformMap(&[_][:0]const u8{
	"test",
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
	_ = scene;
	_ = self;
}

pub fn deinit(self: *Self) void {
	self.uniformMap.deinit();
	self.shaderProgram.deinit();
}
