const std = @import("std");

const glfw = @import("glfw.zig");

const Engine = @import("engine/Engine.zig");
const Window = @import("engine/Window.zig");

fn inputCb(pointer: ?*anyopaque, keyStateMap: Window.KeyStateMap, diffTime: i64) void {
	const engine: ?*Engine = @ptrCast(@alignCast(pointer));
	_ = engine;

	if (keyStateMap.isDown(glfw.Key.d)) {
		std.log.info("diff: {}", .{diffTime});
	}
}

pub fn main() !void {
	// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
	// defer arena.deinit();
	// const allocator = arena.allocator();
	std.log.info("test", .{});
	const allocator = std.heap.c_allocator;
	try glfw.initError();
	defer glfw.deinit();
	var engine: Engine = undefined;
	engine = try Engine.init("test", .{
		.height = 500,
		.width = 500,
		.pointer = &engine,
		.inputCb = inputCb,
	}, allocator);
	defer engine.deinit();
	try engine.run();
}
