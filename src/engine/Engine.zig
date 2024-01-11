const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");

const Window = @import("Window.zig");
const Renderer = @import("Renderer.zig");

const Self = @This();

window: Window,
renderer: Renderer,

pub fn init(title: [*:0]const u8, comptime opts: Window.WindowOptions) !Self {
	std.log.info("Engine: init.", .{});
	const window = try Window.init(title, opts);

	return Self {
		.window = window,
		.renderer = Renderer.init(),
	};
}

pub fn run(self: *Self) !void {

	while (!self.window.handle.shouldClose()) {
		self.window.pollEvents();


	}
}

pub fn deinit(self: Self) void {
	self.window.deinit();
	self.renderer.deinit();
}
