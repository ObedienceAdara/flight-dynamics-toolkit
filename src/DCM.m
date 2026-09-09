function H = DCM(Phi, Theta, Psi)
%DCM  Earth-to-body-axis rotation (direction-cosine) matrix from Euler angles.
%   H = DCM(Phi, Theta, Psi) returns the 3x3 rotation matrix that maps a
%   vector from the earth-relative frame to the body-axis frame, given the
%   roll (Phi), pitch (Theta), and yaw (Psi) Euler angles in radians.
%
%   Behavior-preserving refactor of the original DCM.m; only argument
%   validation was added.
%
%   Original: Copyright 2023-2024 by Robert F. Stengel. All rights reserved.

arguments
    Phi   (1, 1) double {mustBeReal, mustBeFinite}
    Theta (1, 1) double {mustBeReal, mustBeFinite}
    Psi   (1, 1) double {mustBeReal, mustBeFinite}
end

sinR = sin(Phi); cosR = cos(Phi);
sinP = sin(Theta); cosP = cos(Theta);
sinY = sin(Psi); cosY = cos(Psi);

H = zeros(3, 3);
H(1, 1) = cosP * cosY;
H(1, 2) = cosP * sinY;
H(1, 3) = -sinP;
H(2, 1) = sinR * sinP * cosY - cosR * sinY;
H(2, 2) = sinR * sinP * sinY + cosR * cosY;
H(2, 3) = sinR * cosP;
H(3, 1) = cosR * sinP * cosY + sinR * sinY;
H(3, 2) = cosR * sinP * sinY - sinR * cosY;
H(3, 3) = cosR * cosP;
end
