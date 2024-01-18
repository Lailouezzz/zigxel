const std = @import("std");

const glfw = @import("glfw.zig");
const config = @import("engine/config.zig");

const Engine = @import("engine/Engine.zig");
const Window = @import("engine/Window.zig");

fn inputCb(pointer: ?*anyopaque, keyStateMap: Window.KeyStateMap, diffTime: i64) void {
	const engine: *Engine = @as(?*Engine, @ptrCast(@alignCast(pointer))).?;
	const cursorPos = engine.window.handle.getCursorPos();
	_ = diffTime;

	if (keyStateMap.isDown(glfw.Key.escape)) engine.window.handle.setShouldClose(true);

	engine.scene.camera.movePitch(-config.camera.MOUSE_SENSIVITY * @as(f32, @floatCast(cursorPos.ypos)));
	engine.scene.camera.moveYaw(-config.camera.MOUSE_SENSIVITY * @as(f32, @floatCast(cursorPos.xpos)));
	engine.scene.camera.update();

	if (keyStateMap.isDown(glfw.Key.w)) engine.scene.camera.moveForward(config.camera.CAMERA_VELOCITY);
	if (keyStateMap.isDown(glfw.Key.s)) engine.scene.camera.moveBackward(config.camera.CAMERA_VELOCITY);
	if (keyStateMap.isDown(glfw.Key.a)) engine.scene.camera.moveLeft(config.camera.CAMERA_VELOCITY);
	if (keyStateMap.isDown(glfw.Key.d)) engine.scene.camera.moveRight(config.camera.CAMERA_VELOCITY);

	engine.window.handle.setCursorPos(0, 0);
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
