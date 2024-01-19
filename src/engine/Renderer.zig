const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");

const Self = @This();

const Scene = @import("Scene.zig");
const Window = @import("Window.zig");
const ChunkRenderer = @import("ChunkRenderer.zig");
const SkyBoxRenderer = @import("SkyBoxRenderer.zig");

chunkRenderer: ChunkRenderer,
skyBoxRenderer: SkyBoxRenderer,

pub fn init() !Self {
	gl.enable(gl.DEPTH_TEST);
	// gl.enable(gl.CULL_FACE);
	// gl.cullFace(gl.BACK);
	return Self {
		.chunkRenderer = try ChunkRenderer.init(),
		.skyBoxRenderer = try SkyBoxRenderer.init(),
	};
}

pub fn render(self: Self, scene: Scene, window: Window) void {
	gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
	gl.viewport(0, 0, @intCast(window.width), @intCast(window.height));

	self.skyBoxRenderer.render(scene);
	self.chunkRenderer.render(scene);
}

pub fn deinit(self: *Self) void {
	self.chunkRenderer.deinit();
	self.skyBoxRenderer.deinit();
}
