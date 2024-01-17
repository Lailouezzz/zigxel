const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm").SpecializeOn(gl.GLfloat);
const toRadians = @import("zlm").toRadians;

const Self = @This();

const Camera = @import("Camera.zig");
const Terrain = @import("Terrain.zig");

camera: Camera,
fov: f32,
projection: zlm.Mat4 = undefined,
terrain: Terrain,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator) !Self {
	return Self {
		.camera = Camera.init(zlm.vec3(1, 1, 1), zlm.vec3(0, 0, 0).normalize()),
		.fov = toRadians(70.0),
		.terrain = try Terrain.init(),
		.allocator = allocator,
	};
}

pub fn updateProj(self: *Self, width: u32, height: u32) void {
	self.projection = zlm.Mat4.createPerspective(self.fov, @as(f32, @floatFromInt(width)) / @as(f32, @floatFromInt(height)), 0.001, 10000);
}

pub fn deinit(self: *Self) void {
	self.terrain.deinit();
}
