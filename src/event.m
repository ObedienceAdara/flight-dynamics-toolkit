function [value, isterminal, direction] = event(t, x)
%EVENT  ODE event: stop integration when altitude crosses zero (ground impact).
%   [value, isterminal, direction] = EVENT(t, x) is an odeset 'Events'
%   callback. It stops the simulation when x(6), the negative-altitude
%   state (positive down), increases through zero -- i.e., when the
%   vehicle descends through ground level.
%
%   Behavior-preserving refactor of the original event.m; only argument
%   validation was added.
%
%   Original: Copyright 2023 by Robert F. Stengel. All rights reserved.

arguments
    t (1, 1) double {mustBeReal}
    x (:, 1) double {mustBeReal}
end

value      = real(x(6));
isterminal = 1;
direction  = 1;
end
