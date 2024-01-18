const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");

const Window = @import("Window.zig");
const Scene = @import("Scene.zig");
const Renderer = @import("Renderer.zig");

const Self = @This();

window: *Window,
renderer: Renderer,
scene: Scene,
allocator: std.mem.Allocator,

pub fn init(title: [*:0]const u8, opts: Window.WindowOptions, allocator: std.mem.Allocator) !Self {
	defer std.log.info("Engine: initialized.", .{});

	return Self {
		.window = try Window.create(title, opts, allocator),
		.renderer = try Renderer.init(),
		.scene = try Scene.init(allocator),
		.allocator = allocator,
	};
}

pub fn run(self: *Self) !void {
	var lastTime = std.time.microTimestamp();

	while (!self.window.handle.shouldClose()) {
		const now = std.time.microTimestamp();

		self.window.pollEvents();
		self.window.update(now - lastTime);

		self.scene.updateProj(self.window.width, self.window.height);
		self.renderer.render(self.scene, self.window.*);
		self.window.swapBuffers();

		lastTime = now;
	}
}

pub fn deinit(self: *Self) void {
	self.window.destroy();
	self.renderer.deinit();
	self.scene.deinit();
}
