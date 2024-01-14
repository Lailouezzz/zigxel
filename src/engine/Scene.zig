const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm");

const Self = @This();

camera: zlm.Vec3,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator) !Self {
	return Self {
		.camera = zlm.vec3(0, 0, 0),
		.allocator = allocator,
	};
}

pub fn deinit(self: *Self) void {
	_ = self;
}
