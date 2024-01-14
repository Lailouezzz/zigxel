const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm").SpecializeOn(gl.GLfloat);

const Self = @This();

const Camera = @import("Camera.zig");

camera: Camera,
fov: f32,
projection: zlm.Mat4 = undefined,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator) !Self {
	return Self {
		.camera = Camera.init(zlm.vec3(1, 1, 1), zlm.vec3(-1, -1, -1).normalize()),
		.fov = 60,
		.allocator = allocator,
	};
}

pub fn updateProj(self: *Self, width: u32, height: u32) void {
	self.projection = zlm.Mat4.createPerspective(self.fov, @as(f32, @floatFromInt(width)) / @as(f32, @floatFromInt(height)), 0.001, 10000);
}

pub fn deinit(self: *Self) void {
	_ = self;
}
