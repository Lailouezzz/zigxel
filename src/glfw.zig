const std = @import("std");

const glfw = @import("mach-glfw");

pub const gl = @import("gl");

pub usingnamespace glfw;

fn errorCallback(errCode: glfw.ErrorCode, description: [:0]const u8) void {
	std.log.err("GLFW: {s} ({any}).", .{description, errCode});
}

fn glGetProcAddress(p: glfw.GLProc, proc: [:0]const u8) ?gl.FunctionPointer {
	_ = p;
	return glfw.getProcAddress(proc);
}

// init of GLFW and error handling.
pub fn initError() !void {
	glfw.setErrorCallback(errorCallback);
	if (!glfw.init(.{})) {
		return glfw.getErrorCode();
	}
	errdefer glfw.terminate();
}

pub fn deinit() void {
	glfw.terminate();
}
