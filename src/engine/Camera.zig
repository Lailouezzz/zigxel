const std = @import("std");
const cos = std.math.cos;
const sin = std.math.sin;

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm").SpecializeOn(gl.GLfloat);
const config = @import("config.zig");

const Self = @This();

pos: zlm.Vec3,
yaw: gl.GLfloat,
pitch: gl.GLfloat,
dir: zlm.Vec3,

pub const up = zlm.vec3(0, 1, 0);

pub fn init(pos: zlm.Vec3, yaw: gl.GLfloat, pitch: gl.GLfloat) Self {
	var self = Self {
		.pos = pos,
		.yaw = yaw,
		.pitch = pitch,
		.dir = undefined,
	};

	self.update();
	return self;
}

pub fn lookMatrix(self: Self) zlm.Mat4 {
	return zlm.Mat4.createLook(self.pos, self.dir, up);
}

pub fn moveYaw(self: *Self, delta: gl.GLfloat) void {
	self.yaw += delta;
}

pub fn movePitch(self: *Self, delta: gl.GLfloat) void {
	self.pitch = std.math.clamp(self.pitch + delta, -config.camera.PITCH_MAX, config.camera.PITCH_MAX);
	// self.pitch += delta;
}

pub fn moveForward(self: *Self, delta: gl.GLfloat) void {
	self.pos = self.pos.add(self.dir.scale(delta));
}

pub fn moveBackward(self: *Self, delta: gl.GLfloat) void {
	self.moveForward(-delta);
}

pub fn moveLeft(self: *Self, delta: gl.GLfloat) void {
	const right = self.dir.cross(up).normalize();

	self.pos = self.pos.add(right.scale(delta));
}

pub fn moveRight(self: *Self, delta: gl.GLfloat) void {
	self.moveLeft(-delta);
}

pub fn moveUp(self: *Self, delta: gl.GLfloat) void {
	self.pos = self.pos.add(up.scale(delta));
}

pub fn moveDown(self: *Self, delta: gl.GLfloat) void {
	self.moveUp(-delta);
}

pub fn update(self: *Self) void {
	self.dir.x = cos(self.yaw) * cos(self.pitch);
	self.dir.y = sin(self.pitch);
	self.dir.z = sin(self.yaw) * cos(self.pitch);
}
