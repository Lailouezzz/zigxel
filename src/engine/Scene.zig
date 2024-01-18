const std = @import("std");

const config = @import("config.zig");
const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm").SpecializeOn(gl.GLfloat);
const toRadians = @import("zlm").toRadians;

const Self = @This();

const Camera = @import("Camera.zig");
const Terrain = @import("Terrain.zig");

camera: Camera,
projection: zlm.Mat4 = undefined,
terrain: Terrain,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator) !Self {
	return Self {
		.camera = Camera.init(zlm.vec3(0, 0, 0), 0, 0),
		.terrain = blk: {
			var terrain = Terrain.init(allocator);
			try terrain.gen(@truncate(std.time.milliTimestamp()));
			break :blk terrain;
		},
		.allocator = allocator,
	};
}

pub fn updateProj(self: *Self, width: u32, height: u32) void {
	self.projection = zlm.Mat4.createPerspective(config.camera.FOV, @as(f32, @floatFromInt(width)) / @as(f32, @floatFromInt(height)), config.camera.NEAR, config.camera.FAR);
}

pub fn deinit(self: *Self) void {
	self.terrain.deinit();
}
