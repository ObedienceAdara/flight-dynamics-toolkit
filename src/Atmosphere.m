function [airDens, airPres, temp, soundSpeed] = Atmosphere(geomAlt)
%ATMOSPHERE  1976 U.S. Standard Atmosphere interpolation.
%   [airDens, airPres, temp, soundSpeed] = ATMOSPHERE(geomAlt) returns the
%   air density (kg/m^3), air pressure (N/m^2), air temperature (K), and
%   speed of sound (m/s) at the given geometric altitude (m, positive up).
%
%   This is a direct, behavior-preserving refactor of the original Atmos.m
%   from Stengel's FLIGHTv2.m toolkit: same tables, same interpolation
%   scheme. It differs only in adding argument validation and a package-
%   friendly, self-documenting name.
%
%   Note: does not extrapolate outside the tabulated altitude range
%   (-1000 m to 51000 m).
%
%   Reference: Stengel, R. F., "Flight Dynamics," 2nd ed., Appendix B.
%   Original: Copyright 2024 by Robert F. Stengel. All rights reserved.

arguments
    geomAlt (1, 1) double {mustBeReal, mustBeFinite}
end

Z   = [-1000, 0, 2500, 5000, 10000, 11100, 15000, 20000, 47400, 51000];
H   = [-1000, 0, 2499, 4996, 9984, 11081, 14965, 19937, 47049, 50594];
ppo = [1, 1, 0.737, 0.533, 0.262, 0.221, 0.12, 0.055, 0.0011, 0.0007];
rro = [1, 1, 0.781, 0.601, 0.338, 0.293, 0.159, 0.073, 0.0011, 0.0007];
T   = [288.15, 288.15, 271.906, 255.676, 223.252, 216.65, 216.65, 216.65, ...
       270.65, 270.65];
a   = [340.294, 340.294, 330.563, 320.545, 299.532, 295.069, 295.069, ...
       295.069, 329.799, 329.799];
R    = 6367435;
Dens = 1.225;
Pres = 101300;

if geomAlt < Z(1) || geomAlt > Z(end)
    error('Atmosphere:AltitudeOutOfRange', ...
        'Altitude %.1f m is outside the tabulated range [%.0f, %.0f] m.', ...
        geomAlt, Z(1), Z(end));
end

geopAlt = R * geomAlt / (R + geomAlt);
temp       = interp1(H, T, geopAlt);
soundSpeed = interp1(H, a, geopAlt);

airDens = [];
airPres = [];
for k = 2:10
    if geomAlt <= Z(k)
        betap   = log(ppo(k) / ppo(k - 1)) / (Z(k) - Z(k - 1));
        betar   = log(rro(k) / rro(k - 1)) / (Z(k) - Z(k - 1));
        airPres = Pres * ppo(k - 1) * exp(betap * (geomAlt - Z(k - 1)));
        airDens = Dens * rro(k - 1) * exp(betar * (geomAlt - Z(k - 1)));
        break
    end
end
end
