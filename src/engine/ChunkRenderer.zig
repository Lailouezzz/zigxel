const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");

const Self = @This();

const Scene = @import("Scene.zig");

pub fn init() Self {
	return Self {

	};
}

pub fn render(self: Self, scene: Scene) void {
	_ = self;
	_ = scene;
}

pub fn deinit(self: *Self) void {
	_ = self;
}
