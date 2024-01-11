const std = @import("std");

const glfw = @import("glfw.zig");

const Engine = @import("engine/Engine.zig");

pub fn main() !void {
	try glfw.initError();
	defer glfw.deinit();
	var engine = try Engine.init("test", .{
		.height = 500,
		.width = 500,
	});
	defer engine.deinit();
	try engine.run();
}
