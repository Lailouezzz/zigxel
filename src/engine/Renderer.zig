const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");

const Self = @This();

const Scene = @import("Scene.zig");
const Window = @import("Window.zig");
const ChunkRenderer = @import("ChunkRenderer.zig");

chunkRenderer: ChunkRenderer,

pub fn init() Self {
	return Self {
		.chunkRenderer = ChunkRenderer.init(),
	};
}

pub fn render(self: Self, scene: Scene, window: Window) !void {
	gl.clear(gl.COLOR_BUFFER_BIT);
	gl.viewport(0, 0, window.width, window.height);

	self.chunkRenderer.render(scene);
}

pub fn deinit(self: *Self) void {
	self.chunkRenderer.deinit();
}
