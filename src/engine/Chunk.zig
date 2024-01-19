const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm").SpecializeOn(gl.GLfloat);
const znoise = @import("znoise");

const Self = @This();

const Terrain = @import("Terrain.zig");

pub const CHUNK_SIZE = 64;

pub const Block = u8;

//			X			Y			Z
blocks: [CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE]Block = undefined,
pos: [3]i32,
verticesCount: usize = undefined,
vao: gl.GLuint = undefined,
vbo: gl.GLuint = undefined,

pub fn init(x: i32, y: i32, z: i32) !Self {
	var self = Self {
		.pos = .{x, y, z},
	};
	@memset(&self.blocks, 0);
	return self;
}

fn makeMeshData(x: anytype, y: anytype, z: anytype, faceId: anytype, voxelId: anytype, nx: anytype, ny: anytype, nz: anytype) [8]u8 {
	return .{x, y, z, faceId, voxelId, @bitCast(@as(i8, nx)), @bitCast(@as(i8, ny)), @bitCast(@as(i8, nz))};
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

fn meshAppendBack(vertices: *std.ArrayList([8]u8), x: u8, y: u8, z: u8, current: Block) !void {
	const v0 = makeMeshData(x + 1, y, z, 2, current, 1, 0, 0);
	const v1 = makeMeshData(x + 1, y + 1, z, 2, current, 1, 0, 0);
	const v2 = makeMeshData(x + 1, y + 1, z + 1, 2, current, 1, 0, 0);
	const v3 = makeMeshData(x + 1, y, z + 1, 2, current, 1, 0, 0);
	try vertices.appendSlice(&makeMeshFace(
		v0,
		v2,
		v1,
		v0,
		v3,
		v2,
		));
}

fn meshAppendTop(vertices: *std.ArrayList([8]u8), x: u8, y: u8, z: u8, current: Block) !void  {
	const v0 = makeMeshData(x, y + 1, z, 0, current, 0, 1, 0);
	const v1 = makeMeshData(x + 1, y + 1, z , 0, current, 0, 1, 0);
	const v2 = makeMeshData(x + 1, y + 1, z + 1, 0, current, 0, 1, 0);
	const v3 = makeMeshData(x, y + 1, z + 1, 0, current, 0, 1, 0);
	try vertices.appendSlice(&makeMeshFace(
		v0,
		v2,
		v3,
		v0,
		v1,
		v2,
		));
}

fn meshAppendBottom(vertices: *std.ArrayList([8]u8), x: u8, y: u8, z: u8, current: Block) !void  {
	const v0 = makeMeshData(x, y, z, 1, current, 0, -1, 0);
	const v1 = makeMeshData(x + 1, y, z, 1, current, 0, -1, 0);
	const v2 = makeMeshData(x + 1, y, z + 1, 1, current, 0, -1, 0);
	const v3 = makeMeshData(x, y, z + 1, 1, current, 0, -1, 0);
	try vertices.appendSlice(&makeMeshFace(
		v0,
		v3,
		v2,
		v0,
		v2,
		v1,
		));
}
fn meshAppendFront(vertices: *std.ArrayList([8]u8), x: u8, y: u8, z: u8, current: Block) !void  {
	const v0 = makeMeshData(x, y, z, 2, current, 1, 0, 0);
	const v1 = makeMeshData(x, y + 1, z, 2, current, 1, 0, 0);
	const v2 = makeMeshData(x, y + 1, z + 1, 2, current, 1, 0, 0);
	const v3 = makeMeshData(x, y, z + 1, 2, current, 1, 0, 0);
	try vertices.appendSlice(&makeMeshFace(
		v0,
		v1,
		v2,
		v0,
		v2,
		v3,
		));
}
fn meshAppendLeft(vertices: *std.ArrayList([8]u8), x: u8, y: u8, z: u8, current: Block) !void  {
	const v0 = makeMeshData(x, y, z + 1, 4, current, 0, 0, 1);
	const v1 = makeMeshData(x, y + 1, z + 1, 4, current, 0, 0, 1);
	const v2 = makeMeshData(x + 1, y + 1, z + 1, 4, current, 0, 0, 1);
	const v3 = makeMeshData(x + 1, y, z + 1, 4, current, 0, 0, 1);
	try vertices.appendSlice(&makeMeshFace(
		v0,
		v2,
		v3,
		v0,
		v1,
		v2,
		));
}
fn meshAppendRight(vertices: *std.ArrayList([8]u8), x: u8, y: u8, z: u8, current: Block) !void  {
	const v0 = makeMeshData(x, y, z, 5, current, 0, 0, -1);
	const v1 = makeMeshData(x, y + 1, z, 5, current, 0, 0, -1);
	const v2 = makeMeshData(x + 1, y + 1, z, 5, current, 0, 0, -1);
	const v3 = makeMeshData(x + 1, y, z, 5, current, 0, 0, -1);
	try vertices.appendSlice(&makeMeshFace(
		v0,
		v3,
		v2,
		v0,
		v2,
		v1,
		));
}

pub fn mesh(self: *Self, top: ?*Self, bottom: ?*Self, left: ?*Self, right: ?*Self, front: ?*Self, back: ?*Self) !void {
	var vertices = std.ArrayList([8]u8).init(std.heap.c_allocator);

	// MIDDLE
	for (0..CHUNK_SIZE) |_z| {
		for (0..CHUNK_SIZE) |_y| {
			for (0..CHUNK_SIZE) |_x| {
				const x: u8 = @intCast(_x);
				const y: u8 = @intCast(_y);
				const z: u8 = @intCast(_z);
				const current = self.at(x, y, z).*;
				if (current == 0) continue ;
				if (x < CHUNK_SIZE - 1 and self.isVoid(x + 1, y, z)) {
					try meshAppendBack(&vertices, x, y, z, current);
				}
				if (x > 0 and self.isVoid(@as(i8, @bitCast(x)) - 1, y, z)) {
					try meshAppendFront(&vertices, x, y, z, current);
				}
				if (y < CHUNK_SIZE - 1 and self.isVoid(x, y + 1, z)) {
					try meshAppendTop(&vertices, x, y, z, current);
				}
				if (y > 0 and self.isVoid(x, @as(i8, @bitCast(y)) - 1, z)) {
					try meshAppendBottom(&vertices, x, y, z, current);
				}
				if (z < CHUNK_SIZE - 1 and self.isVoid(x, y, z + 1)) {
					try meshAppendLeft(&vertices, x, y, z, current);
				}
				if (z > 0 and self.isVoid(x, y, @as(i8, @bitCast(z)) - 1)) {
					try meshAppendRight(&vertices, x, y, z, current);
				}
			}
		}
	}
	if (top) |chunk| {
		for (0..CHUNK_SIZE) |_x| {
			for (0..CHUNK_SIZE) |_z| {
				const x: u8 = @intCast(_x);
				const z: u8 = @intCast(_z);
				const current = self.at(x, CHUNK_SIZE - 1, z).*;
				if (current == 0) continue ;
				if (chunk.at(x, 0, z).* == 0) {
					try meshAppendTop(&vertices, x, CHUNK_SIZE - 1, z, current);
				}
			}
		}
	}
	if (bottom) |chunk| {
		for (0..CHUNK_SIZE) |_x| {
			for (0..CHUNK_SIZE) |_z| {
				const x: u8 = @intCast(_x);
				const z: u8 = @intCast(_z);
				const current = self.at(x, 0, z).*;
				if (current == 0) continue ;
				if (chunk.at(x, CHUNK_SIZE - 1, z).* == 0) {
					try meshAppendBottom(&vertices, x, 0, z, current);
				}
			}
		}
	}
	if (left) |chunk| {
		for (0..CHUNK_SIZE) |_x| {
			for (0..CHUNK_SIZE) |_y| {
				const x: u8 = @intCast(_x);
				const y: u8 = @intCast(_y);
				const current = self.at(x, y, CHUNK_SIZE - 1).*;
				if (current == 0) continue ;
				if (chunk.at(x, y, 0).* == 0) {
					try meshAppendLeft(&vertices, x, y, CHUNK_SIZE - 1, current);
				}
			}
		}
	}
	if (right) |chunk| {
		for (0..CHUNK_SIZE) |_x| {
			for (0..CHUNK_SIZE) |_y| {
				const x: u8 = @intCast(_x);
				const y: u8 = @intCast(_y);
				const current = self.at(x, y, 0).*;
				if (current == 0) continue ;
				if (chunk.at(x, y, CHUNK_SIZE - 1).* == 0) {
					try meshAppendRight(&vertices, x, y, 0, current);
				}
			}
		}
	}
	if (front) |chunk| {
		for (0..CHUNK_SIZE) |_y| {
			for (0..CHUNK_SIZE) |_z| {
				const y: u8 = @intCast(_y);
				const z: u8 = @intCast(_z);
				const current = self.at(0, y, z).*;
				if (current == 0) continue ;
				if (chunk.at(CHUNK_SIZE - 1, y, z).* == 0) {
					try meshAppendFront(&vertices, 0, y, z, current);
				}
			}
		}
	}
	if (back) |chunk| {
		for (0..CHUNK_SIZE) |_y| {
			for (0..CHUNK_SIZE) |_z| {
				const y: u8 = @intCast(_y);
				const z: u8 = @intCast(_z);
				const current = self.at(CHUNK_SIZE - 1, y, z).*;
				if (current == 0) continue ;
				if (chunk.at(0, y, z).* == 0) {
					try meshAppendBack(&vertices, CHUNK_SIZE - 1, y, z, current);
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
	gl.vertexAttribIPointer(0, 3, gl.UNSIGNED_BYTE, @sizeOf(@TypeOf(vertices.items[0])), @ptrFromInt(0));
	gl.enableVertexAttribArray(1);
	gl.vertexAttribIPointer(1, 1, gl.UNSIGNED_BYTE, @sizeOf(@TypeOf(vertices.items[0])), @ptrFromInt(3));
	gl.enableVertexAttribArray(2);
	gl.vertexAttribIPointer(2, 1, gl.UNSIGNED_BYTE, @sizeOf(@TypeOf(vertices.items[0])), @ptrFromInt(4));
	gl.enableVertexAttribArray(3);
	gl.vertexAttribIPointer(3, 3, gl.BYTE, @sizeOf(@TypeOf(vertices.items[0])), @ptrFromInt(5));

	gl.bindBuffer(gl.ARRAY_BUFFER, 0);
	gl.bindVertexArray(0);
}

pub fn isVoid(self: *Self, x: anytype, y: anytype, z: anytype) bool {
	if (x >= 0 and x < CHUNK_SIZE and y >= 0 and y < CHUNK_SIZE and z >= 0 and z < CHUNK_SIZE){
		return self.at(@as(u8, @bitCast(x)), @as(u8, @bitCast(y)), @as(u8, @bitCast(z))).* == 0;
	}
	unreachable;
}

pub fn at(self: *Self, x: anytype, y: anytype, z: anytype) *Block {
	return &self.blocks[@as(usize, x) + (@as(usize, y) * CHUNK_SIZE) + (@as(usize, z) * CHUNK_SIZE * CHUNK_SIZE)];
}

pub fn modelMatrix(self: Self) zlm.Mat4 {
	return zlm.Mat4.createTranslationXYZ(@floatFromInt(self.pos[0] * CHUNK_SIZE), @floatFromInt(self.pos[1] * CHUNK_SIZE), @floatFromInt(self.pos[2] * CHUNK_SIZE));
}

pub fn unmesh(self: *Self) void {
	gl.deleteVertexArrays(1, &self.vao);
	gl.deleteBuffers(1, &self.vbo);
}

pub fn deinit(self: *Self) void {
	self.unmesh();
}
