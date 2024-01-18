const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm").SpecializeOn(gl.GLfloat);
const znoise = @import("znoise");

const Self = @This();

const Chunk = @import("Chunk.zig");

pub const CHUNK_COLUMN_HEIGHT = 4;

pub const ChunkColumn = [CHUNK_COLUMN_HEIGHT]Chunk;

pub const ChunkMap = std.AutoHashMap([2]i32, *ChunkColumn);

chunks: ChunkMap,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator) Self {
	return Self {
		.allocator = allocator,
		.chunks = ChunkMap.init(allocator),
	};
}

fn setBlockFromHeight(chunkColumn: *ChunkColumn, height: u32, x: u32, z: u32) void {
	for (0..height) |y| {
		chunkColumn.*[@divTrunc(y, Chunk.CHUNK_SIZE)].at(x, @mod(y, Chunk.CHUNK_SIZE), z).* = @intCast(y);
	}
}

fn getHeightAt(noiser: *znoise.FnlGenerator, x: i32, z: i32) u32 {
	const normalNoise = ((noiser.noise2(@as(f32, @floatFromInt(x)) / 8,
											@as(f32, @floatFromInt(z)) / 8) + 1) / 2);
	return @intFromFloat(normalNoise * CHUNK_COLUMN_HEIGHT * Chunk.CHUNK_SIZE);
}

pub fn genColumn(self: *Self, noiser: *znoise.FnlGenerator, x: i32, z: i32) !void {
	const chunkColumn = try self.allocator.create(ChunkColumn);
	errdefer self.allocator.destroy(chunkColumn);
	for (chunkColumn, 0..) |*chunk, y| {
		chunk.* = try Chunk.init(x, @truncate(@as(isize, @bitCast(y))), z, self);
	}
	for (0..Chunk.CHUNK_SIZE) |inchunkx| {
		for (0..Chunk.CHUNK_SIZE) |inchunkz| {
			const absx = @as(i32, @intCast(inchunkx)) + x * Chunk.CHUNK_SIZE;
			const absz =  @as(i32, @intCast(inchunkz)) + z * Chunk.CHUNK_SIZE;
			setBlockFromHeight(chunkColumn, getHeightAt(noiser, absx, absz), @intCast(inchunkx), @intCast(inchunkz));
		}
	}
	try self.chunks.put(.{x, z}, chunkColumn);
}

pub fn gen(self: *Self, seed: i32) !void {
	var noiser = znoise.FnlGenerator {.fractal_type = .fbm, .seed = seed};

	const width = 2;
	const height = 2;
	var x: i32 = -width;
	while (x < width) : (x += 1) {
		var z: i32 = -height;
		while (z < height) : (z += 1) {
			try self.genColumn(&noiser, x, z);
		}
	}
	var it = self.chunks.valueIterator();
	while (it.next()) |chunkColumn| {
		for (chunkColumn.*) |*chunk| {
			try chunk.mesh();
		}
	}
}

pub fn getChunkColumnFromAbs(self: Self, x: i32, z: i32) ?*ChunkColumn {
	const chunkX = @divTrunc(if (x < 0) x - Chunk.CHUNK_SIZE + 1 else x, Chunk.CHUNK_SIZE);
	const chunkZ = @divTrunc(if (z < 0) z - Chunk.CHUNK_SIZE + 1 else z, Chunk.CHUNK_SIZE);
	return self.chunks.get(.{chunkX, chunkZ});
}

pub fn getChunkFromAbs(self: Self, x: i32, y: i32, z: i32) ?*Chunk {
	const chunkColumn = self.getChunkColumnFromAbs(x, z) orelse return null;
	const chunkY = @divTrunc(if (y < 0) y - Chunk.CHUNK_SIZE + 1 else y, Chunk.CHUNK_SIZE);
	if (chunkY < 0 or chunkY >= CHUNK_COLUMN_HEIGHT) return null;
	return &chunkColumn[@as(u32, @bitCast(chunkY))];
}

pub fn at(self: Self, x: i32, y: i32, z: i32) ?*Chunk.Block {
	const chunk = self.getChunkFromAbs(x, y, z) orelse return null;
	const inchunkX = @as(u32, @bitCast(@mod(x, Chunk.CHUNK_SIZE)));
	const inchunkY = @as(u32, @bitCast(@mod(y, Chunk.CHUNK_SIZE)));
	const inchunkZ = @as(u32, @bitCast(@mod(z, Chunk.CHUNK_SIZE)));
	return chunk.at(inchunkX, inchunkY, inchunkZ);
}

pub fn isVoid(self: Self, x: i32, y: i32, z: i32) bool {
	const block = self.at(x, y, z) orelse return true;
	return block.* == 0;
}

pub fn deinit(self: *Self) void {
	var it = self.chunks.valueIterator();

	while (it.next()) |chunkColumn| {
		for (0..CHUNK_COLUMN_HEIGHT) |y| {
			chunkColumn.*.*[y].deinit();
		}
		self.allocator.destroy(chunkColumn.*);
	}
	self.chunks.deinit();
}
