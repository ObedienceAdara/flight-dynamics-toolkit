function q = euler2quat(phi, theta, psi)
%EULER2QUAT  Convert Euler angles (rad) to a quaternion [q1; q2; q3; q4].
%   q4 is the scalar (cos-half-angle) component. This is a direct
%   extraction of the quaternion-initialization snippet that used to be
%   written inline in FLIGHTv2.m Section 6B, given its own name and tests
%   so it can be reused (e.g. by run_flight.m to convert a scenario's
%   Euler-angle initial condition into the 13-element quaternion state).
%
%   Original: Copyright 2023 by Robert F. Stengel. All rights reserved.

arguments
    phi   (1, 1) double
    theta (1, 1) double
    psi   (1, 1) double
end

H  = DCM(phi, theta, psi);
q4 = 0.5 * sqrt(1 + H(1, 1) + H(2, 2) + H(3, 3));
q1 = (H(2, 3) - H(3, 2)) / (4 * q4);
q2 = (H(3, 1) - H(1, 3)) / (4 * q4);
q3 = (H(1, 2) - H(2, 1)) / (4 * q4);
q  = [q1; q2; q3; q4];
end
