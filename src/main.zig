const std = @import("std");

const glfw = @import("glfw.zig");

const Engine = @import("engine/Engine.zig");

fn keycb(pointer: ?*anyopaque, key: glfw.Key, scancode: i32, action: glfw.Action, mods: glfw.Mods) void {
	const engine = @as(?*Engine, @ptrCast(@alignCast(pointer.?))).?;
	_ = key;
	_ = scancode;
	_ = action;
	_ = mods;
	std.log.info("Key press. {}", .{engine.window.width});
}

pub fn main() !void {
	// var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
	// defer arena.deinit();
	// const allocator = arena.allocator();
	const allocator = std.heap.c_allocator;
	try glfw.initError();
	defer glfw.deinit();
	var engine: Engine = undefined;
	engine = try Engine.init("test", .{
		.height = 500,
		.width = 500,
		.pointer = &engine,
		.keycb = keycb,
	}, allocator);
	defer engine.deinit();
	try engine.run();
}
