const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm").SpecializeOn(gl.GLfloat);

const Self = @This();

vao: gl.GLuint,
vbo: gl.GLuint,

pub fn init() !Self {
	var vao: gl.GLuint = undefined;
	gl.createVertexArrays(1, &vao);
	errdefer gl.deleteVertexArrays(1, &vao);
	gl.bindVertexArray(vao);
	var vbo: gl.GLuint = undefined;
	gl.createBuffers(1, &vbo);
	errdefer gl.deleteBuffers(1, &vbo);
	gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
	var vertices = [_]gl.GLfloat{
	-1.0,-1.0,-1.0, // triangle 1 : begin
	-1.0,-1.0, 1.0,
	-1.0, 1.0, 1.0, // triangle 1 : end
	1.0, 1.0,-1.0, // triangle 2 : begin
	-1.0,-1.0,-1.0,
	-1.0, 1.0,-1.0, // triangle 2 : end
	1.0,-1.0, 1.0,
	-1.0,-1.0,-1.0,
	1.0,-1.0,-1.0,
	1.0, 1.0,-1.0,
	1.0,-1.0,-1.0,
	-1.0,-1.0,-1.0,
	-1.0,-1.0,-1.0,
	-1.0, 1.0, 1.0,
	-1.0, 1.0,-1.0,
	1.0,-1.0, 1.0,
	-1.0,-1.0, 1.0,
	-1.0,-1.0,-1.0,
	-1.0, 1.0, 1.0,
	-1.0,-1.0, 1.0,
	1.0,-1.0, 1.0,
	1.0, 1.0, 1.0,
	1.0,-1.0,-1.0,
	1.0, 1.0,-1.0,
	1.0,-1.0,-1.0,
	1.0, 1.0, 1.0,
	1.0,-1.0, 1.0,
	1.0, 1.0, 1.0,
	1.0, 1.0,-1.0,
	-1.0, 1.0,-1.0,
	1.0, 1.0, 1.0,
	-1.0, 1.0,-1.0,
	-1.0, 1.0, 1.0,
	1.0, 1.0, 1.0,
	-1.0, 1.0, 1.0,
	1.0,-1.0, 1.0
	};
	for (&vertices) |*vertice| {
		vertice.* /= 4;
	}
	gl.bufferData(gl.ARRAY_BUFFER, vertices.len * @sizeOf(@TypeOf(vertices[0])), &vertices, gl.STATIC_DRAW);
	gl.enableVertexAttribArray(0);
	gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, null);
	gl.bindBuffer(gl.ARRAY_BUFFER, 0);
	gl.bindVertexArray(0);
	return Self {
		.vao = vao,
		.vbo = vbo,
	};
}

pub fn deinit(self: *Self) void {
	gl.deleteVertexArrays(1, &self.vao);
	gl.deleteBuffers(1, &self.vbo);
}
