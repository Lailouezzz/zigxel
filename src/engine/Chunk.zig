const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm").SpecializeOn(gl.GLfloat);

const Self = @This();

pub const CHUNK_SIZE = 8;
//			X			Y			Z
blocks: [CHUNK_SIZE][CHUNK_SIZE][CHUNK_SIZE]u8 = undefined,
pos: [2]u32,
vao: gl.GLuint = undefined,
vboVertices: gl.GLuint = undefined,
vboNormals: gl.GLuint = undefined,

pub fn init(x: u32, y: u32) !Self {
	var self = Self {
		.pos = .{x, y},
	};
	for (0..CHUNK_SIZE) |k| {
		for (0..CHUNK_SIZE) |j| {
			self.makeAt(@intCast(k), @intCast(j));
		}
	}
	self.mesh();
	return self;
}

fn mesh(self: *Self) void {
	_ = self;
}

fn makeAt(self: *Self, x: u32, y: u32) void {
	@memset(self.blocks[x][y][0..x], 1);
	@memset(self.blocks[x][y][x..CHUNK_SIZE], 0);
}

pub fn modelMatrix(self: Self) zlm.Mat4 {
	_ = self;
	return zlm.Mat4.identity;
}

pub fn deinit(self: *Self) void {
	_ = self;
}
