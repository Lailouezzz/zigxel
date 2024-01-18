const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm").SpecializeOn(gl.GLfloat);

const Self = @This();

pub const CHUNK_SIZE = 8;
//			X			Y			Z
blocks: [CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE]u8 = undefined,
pos: [2]u32,
verticesCount: usize = undefined,
vao: gl.GLuint = undefined,
vbo: gl.GLuint = undefined,

pub fn init(x: u32, y: u32) !Self {
	var self = Self {
		.pos = .{x, y},
	};
	inline for (0..CHUNK_SIZE) |k| {
		inline for (0..CHUNK_SIZE) |j| {
			self.makeAt(@intCast(k), @intCast(j));
		}
	}
	try self.mesh();
	return self;
}

fn makeMeshData(x: u8, y: u8, z: u8, faceId: u8, voxelId: u8, nx: u8, ny: u8, nz: u8) [8]u8 {
	return .{x, y, z, faceId, voxelId, nx, ny, nz};
}

fn makeMeshFace(v0: [8]u8, v1: [8]u8, v2: [8]u8, v3: [8]u8, v4: [8]u8, v5: [8]u8, ) [6][8]u8 {
	return .{
		v0,
		v1,
		v2,
		v3,
		v4,
		v5,
	};
}

fn mesh(self: *Self) !void {
	var vertices = std.ArrayList([8]u8).init(std.heap.c_allocator);

	for (0..CHUNK_SIZE) |_z| {
		for (0..CHUNK_SIZE) |_y| {
			for (0..CHUNK_SIZE) |_x| {
				const x: u8 = @intCast(_x);
				const y: u8 = @intCast(_y);
				const z: u8 = @intCast(_z);
				const current = self.at(x, y, z).*;
				if (current == 0) continue ;
				if (self.isVoid(x + 1, y, z)) {
					const v0 = makeMeshData(x + 1, y, z, 0, current, 1, 0, 0);
					const v1 = makeMeshData(x + 1, y + 1, z, 0, current, 1, 0, 0);
					const v2 = makeMeshData(x + 1, y + 1, z + 1, 0, current, 1, 0, 0);
					const v3 = makeMeshData(x + 1, y, z, 0, current, 1, 0, 0);
					try vertices.appendSlice(&makeMeshFace(
						v0,
						v1,
						v2,
						v0,
						v2,
						v3));
				}
			}
		}
	}
	gl.createVertexArrays(1, &self.vao);
	errdefer gl.deleteVertexArrays(1, &self.vao);
	gl.bindVertexArray(self.vao);
	gl.createBuffers(1, &self.vbo);
	errdefer gl.deleteBuffers(1, &self.vbo);
	gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo);
	self.verticesCount = vertices.items.len;
	gl.bufferData(gl.ARRAY_BUFFER, @bitCast(vertices.items.len * @sizeOf(@TypeOf(vertices.items[0]))), vertices.items.ptr, gl.STATIC_DRAW);

	gl.enableVertexAttribArray(0);
	gl.vertexAttribPointer(0, 3, gl.UNSIGNED_BYTE, gl.FALSE, @sizeOf(@TypeOf(vertices.items[0])), null);

	gl.bindBuffer(gl.ARRAY_BUFFER, 0);
	gl.bindVertexArray(0);
	std.log.info("{any}", .{vertices.items.len});
}

pub fn isVoid(self: *Self, x: anytype, y: anytype, z: anytype) bool {
	if (x >= 0 and x < CHUNK_SIZE and y >= 0 and y < CHUNK_SIZE and z >= 0 and z < CHUNK_SIZE){
		return self.at(x, y, z).* == 0;
	}
	return true;
}

pub fn at(self: *Self, x: anytype, y: anytype, z: anytype) *u8 {
	return &self.blocks[@as(usize, x) + (@as(usize, y) * CHUNK_SIZE) + (@as(usize, z) * CHUNK_SIZE * CHUNK_SIZE)];
}

fn makeAt(self: *Self, x: u32, y: u32) void {
	_ = x;
	_ = y;
	@memset(&self.blocks, 1);
}

pub fn modelMatrix(self: Self) zlm.Mat4 {
	return zlm.Mat4.createTranslationXYZ(@floatFromInt(self.pos[0] * CHUNK_SIZE), CHUNK_SIZE, @floatFromInt(self.pos[1] * CHUNK_SIZE));
}

pub fn deinit(self: *Self) void {
	gl.deleteVertexArrays(1, self.vao);
	gl.deleteBuffers(1, self.vbo);
}
