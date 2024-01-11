const std = @import("std");

const glfw = @import("glfw.zig");
const gl = @import("gl");

const Window = @import("engine/Window.zig");

pub fn main() !void {
	try glfw.initError();
	defer glfw.deinit();
	var w = try Window.init("test", 500, 500, null, null);
	defer w.deinit();
	var w2 = try Window.init("test2", 500, 500, null, null);
	defer w2.deinit();
	std.time.sleep(1000*1000*1000);
}
