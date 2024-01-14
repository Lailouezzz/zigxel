const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");

const Self = @This();

handle: glfw.Window,
width: u32,
height: u32,
pointer: ?*anyopaque,
keycb: ?*const fn (pointer: ?*anyopaque, key: glfw.Key, scancode:i32, action: glfw.Action, mods: glfw.Mods) void,
allocator: std.mem.Allocator,

fn glGetProcAddress(p: glfw.GLProc, proc: [:0]const u8) ?gl.FunctionPointer {
	_ = p;
	return glfw.getProcAddress(proc);
}

pub fn create(title: [*:0]const u8, opts: WindowOptions, allocator: std.mem.Allocator) !*Self {
	const self = try allocator.create(Self);
	errdefer allocator.destroy(self);
	self.width = opts.width;
	self.height = opts.height;
	self.pointer = opts.pointer;
	self.keycb = opts.keycb;
	self.allocator = allocator;
	self.handle = glfw.Window.create(opts.width, opts.height, title, null, null, .{
		.opengl_profile = .opengl_core_profile,
		.context_version_major = 4,
		.context_version_minor = 5,
	}) orelse return glfw.mustGetErrorCode();
	errdefer self.handle.destroy();
	self.handle.setUserPointer(self);
	self.handle.setFramebufferSizeCallback(struct {
		fn resizecb(window: glfw.Window, width: u32, height: u32) void {
			const s = window.getUserPointer(Self).?;
			s.width = width;
			s.height = height;
		}
	}.resizecb);
	self.handle.setKeyCallback(struct {
		fn keycb(window: glfw.Window, key: glfw.Key, scancode:i32, action: glfw.Action, mods: glfw.Mods) void {
			const s = window.getUserPointer(Self).?;
			if (s.keycb) |cb| {
				cb(s.pointer, key, scancode, action, mods);
			}
		}
	}.keycb);
	glfw.makeContextCurrent(self.handle);
	const proc: glfw.GLProc = undefined;
	try gl.load(proc, glGetProcAddress);
	return self;
}

pub fn pollEvents(self: Self) void {
	_ = self;
	glfw.pollEvents();
}

pub fn update(self: Self) void {
	self.handle.swapBuffers();
}

pub fn destroy(self: *Self) void {
	self.handle.destroy();
	self.allocator.destroy(self);
}

pub const WindowOptions = struct {
	width: u32,
	height: u32,
	pointer: ?*anyopaque,
	keycb: ?*const fn (pointer: ?*anyopaque, key: glfw.Key, scancode:i32, action: glfw.Action, mods: glfw.Mods) void,
};
