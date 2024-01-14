const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm");

const Self = @This();

pos: zlm.Vec3,
dir: zlm.Vec3,

pub fn init(pos: zlm.Vec3, dir: zlm.Vec3) Self {
	return Self {
		.pos = pos,
		.dir = dir,
	};
}

pub fn lookMatrix(self: Self) zlm.Mat4 {
	return zlm.Mat4.createLook(self.pos, self.dir, zlm.vec3(0, 1, 0));
}
