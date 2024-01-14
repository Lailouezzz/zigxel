const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm");

const ShaderProgram = @import("ShaderProgram.zig");

const Error = error {
	UniformNotFount,
};

pub fn UniformMap(comptime uniforms: []const [:0]const u8) type {
	return struct {
		const Self = @This();

		uniformMap: [uniforms.len]gl.GLint = undefined,

		fn idxFromUniform(self: Self, uniform: [:0]const u8) usize {
			_ = self;
			inline for (uniforms, 0..) |uni, k| {
				if (std.mem.eql(u8, uniform, uni)) return k;
			}
			unreachable;
		}

		pub fn init(shaderProgram: ShaderProgram) !Self {
			var self: Self = undefined;
			inline for (uniforms, 0..) |uni, k| {
				self.uniformMap[k] = gl.getUniformLocation(shaderProgram.programId, uni);
				if (self.uniformMap[k] == -1) return Error.UniformNotFount;
			}
			return self;
		}

		pub fn deinit(self: Self) void {
			_ = self;
		}
	};
}
