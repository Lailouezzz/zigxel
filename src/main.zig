const std = @import("std");

const glfw = @import("glfw.zig");
const gl = @import("gl");
const config = @import("engine/config.zig");

const Engine = @import("engine/Engine.zig");
const Window = @import("engine/Window.zig");
const Terrain = @import("engine/Terrain.zig");

fn inputCb(pointer: ?*anyopaque, keyStateMap: Window.KeyStateMap, diffTime: i64) void {
	const engine: *Engine = @as(?*Engine, @ptrCast(@alignCast(pointer))).?;
	const cursorPos = engine.window.handle.getCursorPos();
	const diff: f32 = @as(f32, @floatFromInt(diffTime)) / 1000;

	if (keyStateMap.isDown(glfw.Key.escape)) engine.window.handle.setShouldClose(true);

	engine.scene.camera.movePitch(-config.camera.MOUSE_SENSIVITY * @as(f32, @floatCast(cursorPos.ypos)));
	engine.scene.camera.moveYaw(-config.camera.MOUSE_SENSIVITY * @as(f32, @floatCast(cursorPos.xpos)));
	engine.scene.camera.update();

	const velocity: f32 = @as(f32, if (keyStateMap.isDown(glfw.Key.left_shift)) config.camera.CAMERA_VELOCITY * 2.0 else config.camera.CAMERA_VELOCITY) * diff;

	if (keyStateMap.isDown(glfw.Key.w)) engine.scene.camera.moveForward(velocity);
	if (keyStateMap.isDown(glfw.Key.s)) engine.scene.camera.moveBackward(velocity);
	if (keyStateMap.isDown(glfw.Key.a)) engine.scene.camera.moveLeft(velocity);
	if (keyStateMap.isDown(glfw.Key.d)) engine.scene.camera.moveRight(velocity);
	if (keyStateMap.isDown(glfw.Key.space)) engine.scene.camera.moveUp(velocity);
	if (keyStateMap.isDown(glfw.Key.left_control)) engine.scene.camera.moveDown(velocity);

	if (keyStateMap.isPressed(glfw.Key.f)) {
		const monitor = glfw.Monitor.getPrimary().?;
		engine.window.handle.setMonitor(monitor, 0, 0, monitor.getVideoMode().?.getWidth(), monitor.getVideoMode().?.getHeight(), monitor.getVideoMode().?.getRefreshRate());
		engine.window.handle.setAttrib(.decorated, false);
		glfw.makeContextCurrent(engine.window.handle);
	}
	if (keyStateMap.isPressed(glfw.Key.F4)) gl.polygonMode(gl.FRONT_AND_BACK, gl.LINE);
	if (keyStateMap.isPressed(glfw.Key.F5)) gl.polygonMode(gl.FRONT_AND_BACK, gl.FILL);

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
