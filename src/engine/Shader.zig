const std = @import("std");

const glfw = @import("../glfw.zig");
const gl = @import("gl");

const Self = @This();

const vertexShaderSource = @embedFile("shader/vertex.shad");
