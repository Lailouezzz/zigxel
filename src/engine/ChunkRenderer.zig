const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");

const Self = @This();

const Scene = @import("Scene.zig");
const ShaderProgram = @import("ShaderProgram.zig");

shaderProgram: ShaderProgram,

pub fn init() !Self {
	return Self {
		.shaderProgram = try ShaderProgram.init(&[_]ShaderProgram.ShaderData{
		.{
			.source = @embedFile("shader/vertex.shad"),
			.shaderType = gl.VERTEX_SHADER,
		},
		.{
			.source = @embedFile("shader/frag.shad"),
			.shaderType = gl.FRAGMENT_SHADER,
		},})
	};
}

pub fn render(self: Self, scene: Scene) void {
	_ = self;
	_ = scene;
}

pub fn deinit(self: *Self) void {
	self.shaderProgram.deinit();
}
