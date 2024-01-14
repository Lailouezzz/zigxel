const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");

const Self = @This();

handle: glfw.Window,
width: u32,
height: u32,
pointer: ?*anyopaque,
inputCb: ?*const fn(pointer: ?*anyopaque, keyStateMap: KeyStateMap, diffTime: i64)void,
keyStateMap: KeyStateMap,
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
	self.inputCb = opts.inputCb;
	self.keyStateMap = KeyStateMap.init();
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
			_ = scancode;
			_ = mods;
			s.keyStateMap.updateCb(key, action);
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

pub fn handleInput(self: *Self, diffTime: i64) void {
	if (self.inputCb) |cb| {
		cb(self.pointer, self.keyStateMap, diffTime);
	}
	self.keyStateMap.resetAction();
}

pub fn update(self: Self) void {
	self.handle.swapBuffers();
}

pub fn destroy(self: *Self) void {
	self.keyStateMap.deinit();
	self.handle.destroy();
	self.allocator.destroy(self);
}

pub const WindowOptions = struct {
	width: u32,
	height: u32,
	pointer: ?*anyopaque,
	inputCb: ?*const fn(pointer: ?*anyopaque, keyStateMap: KeyStateMap, diffTime: i64)void,
};

pub const KeyStateMap = struct {
	pub const KeyState = enum {
		Down,
		Up,
	};
	pub const KeyAction = enum {
		Pressed,
		Released,
		None,
	};
	keysState: [@typeInfo(glfw.Key).Enum.fields.len]KeyState,
	keysAction: [@typeInfo(glfw.Key).Enum.fields.len]KeyAction,

	pub fn init() KeyStateMap {
		return KeyStateMap {
			.keysState = [_]KeyState{.Up} ** @typeInfo(glfw.Key).Enum.fields.len,
			.keysAction = [_]KeyAction{.None} ** @typeInfo(glfw.Key).Enum.fields.len,
		};
	}

	pub fn deinit(self: KeyStateMap) void {
		_ = self;
	}

	pub fn isPressed(self: KeyStateMap, key: glfw.Key) bool {
		return self.keysAction[keyToIndex(key)] == .Pressed;
	}

	pub fn isReleased(self: KeyStateMap, key: glfw.Key) bool {
		return self.keysAction[keyToIndex(key)] == .Released;
	}

	pub fn isDown(self: KeyStateMap, key: glfw.Key) bool {
		return self.keysState[keyToIndex(key)] == .Down;
	}

	pub fn isUp(self: KeyStateMap, key: glfw.Key) bool {
		return self.keysState[keyToIndex(key)] == .Up;
	}

	fn keyToIndex(key: glfw.Key) usize {
		inline for (@typeInfo(glfw.Key).Enum.fields, 0..) |field, k| {
			if (field.value == @intFromEnum(key)) return k;
		}
		unreachable;
	}

	fn resetAction(self: *KeyStateMap) void {
		@memset(&self.keysAction, .None);
	}

	fn updateCb(self: *KeyStateMap, key: glfw.Key, action: glfw.Action) void {
		const idx = keyToIndex(key);
		if (action == .release) {
			self.keysState[idx] = .Up;
			self.keysAction[idx] = .Released;
		}
		if (action == .press) {
			self.keysState[idx] = .Down;
			self.keysAction[idx] = .Pressed;
		}
	}
};
