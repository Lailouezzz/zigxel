const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");

const Self = @This();

handle: glfw.Window,
width: u32,
height: u32,

fn glGetProcAddress(p: glfw.GLProc, proc: [:0]const u8) ?gl.FunctionPointer {
	_ = p;
	return glfw.getProcAddress(proc);
}

pub fn init(title: [*:0]const u8, width: u32, height: u32, comptime resizecb: ?fn(glfw.Window, u32, u32) void, comptime keycb: ?fn(glfw.Window, glfw.Key, i32, glfw.Action, glfw.Mods) void) !Self {
	const handle = glfw.Window.create(width, height, title, null, null, .{
		.opengl_profile = .opengl_core_profile,
		.context_version_major = 4,
		.context_version_minor = 5,
	}) orelse return glfw.mustGetErrorCode();
	handle.setFramebufferSizeCallback(resizecb);
	handle.setKeyCallback(keycb);
	glfw.makeContextCurrent(handle);
	const proc: glfw.GLProc = undefined;
	try gl.load(proc, glGetProcAddress);
	return Self {
		.handle = handle,
		.width = width,
		.height = height,
	};
}

pub fn pollEvents(self: Self) void {
	_ = self;
	glfw.pollEvents();
}

pub fn deinit(self: Self) void {
	self.handle.destroy();
}
