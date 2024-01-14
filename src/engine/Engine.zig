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
	std.log.info("Engine: init.", .{});

	return Self {
		.window = try Window.create(title, opts, allocator),
		.renderer = try Renderer.init(),
		.scene = try Scene.init(),
		.allocator = allocator,
	};
}

pub fn run(self: *Self) !void {
	while (!self.window.handle.shouldClose()) {
		self.window.pollEvents();

		self.window.handleInput();

		self.renderer.render(self.scene, self.window.*);

		self.window.update();
	}
}

pub fn deinit(self: *Self) void {
	self.window.destroy();
	self.renderer.deinit();
}
