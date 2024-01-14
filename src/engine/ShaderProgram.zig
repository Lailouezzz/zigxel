const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");

const Self = @This();

const Error = error {
	ProgramError,
	ShaderError,
};

programId: gl.GLuint,

pub fn init(shadersData: []const ShaderData) !Self {
	const programId = gl.createProgram();
	if (programId == 0) return Error.ProgramError;
	const self = Self {
		.programId = programId,
	};
	for (shadersData) |shader| {
		try self.addShader(shader.source, shader.shaderType);
	}
	gl.linkProgram(self.programId);
	return self;
}

pub fn deinit(self: Self) void {
	self.unbind();
	if (self.programId != 0) gl.deleteProgram(self.programId);
}

pub fn bind(self: Self) void {
	gl.useProgram(self.programId);
}

pub fn unbind(self: Self) void {
	_ = self;
	gl.useProgram(0);
}

fn addShader(self: Self, source: [*:0]const u8, shaderType: gl.GLenum) !void {
	const shaderId = gl.createShader(shaderType);
	if (shaderId == 0) return Error.ShaderError;
	gl.shaderSource(shaderId, 1, &source, null);
	gl.compileShader(shaderId);

	var s: gl.GLint = undefined;
	gl.getShaderiv(shaderId, gl.COMPILE_STATUS, &s);
	if (s != gl.TRUE) {
		const bufLen: comptime_int = 1024;
		var msg = [_]u8{0} ** bufLen;
		gl.getShaderInfoLog(shaderId, bufLen, null, &msg);
		std.log.err("Shader compile error : {s}.", .{msg});
		return Error.ShaderError;
	}
	gl.attachShader(self.programId, shaderId);
}

pub const ShaderData = struct {
	source: [*:0]const u8,
	shaderType: gl.GLenum,
};
