const zlm = @import("zlm");

// pub const default = struct {
	pub const camera = struct {
		pub const NEAR = 0.01;
		pub const FAR = 10000;

		pub const FOV = zlm.toRadians(80.0);

		pub const CAMERA_VELOCITY = 0.1;
		pub const PITCH_MAX = zlm.toRadians(89.0);
		pub const MOUSE_SENSIVITY = 0.002;
	};
// };
