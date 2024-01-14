const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");

const Self = @This();

camera: u32,

pub fn init() !Self {
	return Self {
		.camera = 0xdeadbeef,
	};
}

pub fn deinit(self: *Self) void {
	_ = self;
}
