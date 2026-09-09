function euler = quat2euler(q)
%QUAT2EULER  Convert a quaternion trajectory to Euler angles (rad).
%   euler = QUAT2EULER(q), where q is Nx4 = [q1 q2 q3 q4] (q4 scalar
%   component), returns euler as Nx3 = [phi theta psi] in radians.
%
%   Direct extraction of the post-processing formulas from FLIGHTv2.m
%   Section 6B (previously written inline, applied only once, right after
%   a quaternion-mode ode45 call). Given its own name and tests here so it
%   can be reused by computeFlightQuantities.m or any other consumer of a
%   quaternion trajectory.
%
%   Original: Copyright 2023 by Robert F. Stengel. All rights reserved.

arguments
    q (:, 4) double
end

q1 = q(:, 1);
q2 = q(:, 2);
q3 = q(:, 3);
q4 = q(:, 4);

phi   = atan2(2 * (q1 .* q4 + q2 .* q3), (1 - 2 * (q1.^2 + q2.^2)));
theta = asin(2 * (q2 .* q4 - q1 .* q3));
psi   = atan2(2 * (q3 .* q4 + q1 .* q2), (1 - 2 * (q2.^2 + q3.^2)));

euler = [phi, theta, psi];
end
