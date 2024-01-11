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

pub fn init(title: [*:0]const u8, comptime opts: WindowOptions) !Self {
	const handle = glfw.Window.create(opts.width, opts.height, title, null, null, .{
		.opengl_profile = .opengl_core_profile,
		.context_version_major = 4,
		.context_version_minor = 5,
		.resizable = false,
	}) orelse return glfw.mustGetErrorCode();
	glfw.makeContextCurrent(handle);
	handle.setFramebufferSizeCallback(struct {
		fn resizecb(window: glfw.Window, width: u32, height: u32) void {
			const self = window.getUserPointer(*Self) orelse unreachable;

		}
	}.resizecb);
	const proc: glfw.GLProc = undefined;
	try gl.load(proc, glGetProcAddress);
	return Self {
		.handle = handle,
		.width = opts.width,
		.height = opts.height,
	};
}

pub fn pollEvents(self: Self) void {
	_ = self;
	glfw.pollEvents();
}

pub fn update(self: Self) void {
	self.handle.swapBuffers();
}

pub fn deinit(self: Self) void {
	self.handle.destroy();
}

pub const WindowOptions = struct {
	width: u32,
	height: u32,
};
