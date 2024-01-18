const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm").SpecializeOn(gl.GLfloat);

const Self = @This();

const Chunk = @import("Chunk.zig");

chunk: [2][2]Chunk = undefined,

pub fn init() !Self {
	var self = Self {};
	for (0..2) |x| {
		for (0..2) |y| {
			self.chunk[x][y] = try Chunk.init(@intCast(x), @intCast(y));
		}
	}
	return self;
}

pub fn deinit(self: *Self) void {
	for (0..2) |x| {
		for (0..2) |y| {
			self.chunk[x][y].deinit();
		}
	}
}
