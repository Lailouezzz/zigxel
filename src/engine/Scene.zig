const std = @import("std");

const config = @import("config.zig");
const glfw = @import("../glfw.zig");
const gl = @import("gl");
const zlm = @import("zlm").SpecializeOn(gl.GLfloat);
const toRadians = @import("zlm").toRadians;

const Self = @This();

const Camera = @import("Camera.zig");
const Terrain = @import("Terrain.zig");

camera: Camera,
projection: zlm.Mat4 = undefined,
terrain: Terrain,
vao: gl.GLuint,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator) !Self {
	var vao: gl.GLuint = undefined;

	gl.createVertexArrays(1, &vao);
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
	gl.bufferData(gl.ARRAY_BUFFER, vertices.len * @sizeOf(@TypeOf(vertices[0])), &vertices, gl.STATIC_DRAW);
	gl.enableVertexAttribArray(0);
	gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, null);
	gl.bindBuffer(gl.ARRAY_BUFFER, 0);
	gl.bindVertexArray(0);
	return Self {
		.camera = Camera.init(zlm.vec3(0, 0, 0), 0, 0),
		.terrain = try Terrain.init(),
		.vao = vao,
		.allocator = allocator,
	};
}

pub fn updateProj(self: *Self, width: u32, height: u32) void {
	self.projection = zlm.Mat4.createPerspective(config.camera.FOV, @as(f32, @floatFromInt(width)) / @as(f32, @floatFromInt(height)), config.camera.NEAR, config.camera.FAR);
}

pub fn deinit(self: *Self) void {
	self.terrain.deinit();
}
