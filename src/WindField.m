function windb = WindField(height, phir, thetar, psir)
%WINDFIELD  Body-axis wind vector as a function of altitude.
%   windb = WINDFIELD(height, phir, thetar, psir) interpolates a
%   three-component earth-relative wind vector as a function of altitude
%   and rotates it into body axes using the current Euler angles.
%
%   All tabulated wind components are zero by default (still-air). To model
%   a steady wind or shear profile, edit windx/windy/windz below, or -- for
%   a cleaner extension path -- replace calls to WindField with a
%   WindModel object that supports Dryden/von Karman turbulence.
%
%   Behavior-preserving refactor of the original WindField.m (previously
%   distributed as WindFieldv2.m; renamed here to match its function name,
%   since MATLAB resolves calls by filename); only argument validation was
%   added.
%
%   Original: Copyright 2023 by Robert F. Stengel. All rights reserved.

arguments
    height (1, 1) double {mustBeReal, mustBeFinite}
    phir   (1, 1) double {mustBeReal, mustBeFinite}
    thetar (1, 1) double {mustBeReal, mustBeFinite}
    psir   (1, 1) double {mustBeReal, mustBeFinite}
end

windh = [-10 0 100 200 500 1000 2000 4000 8000 16000];
windx = [0 0 0 0 0 0 0 0 0 0];
windy = [0 0 0 0 0 0 0 0 0 0];
windz = [0 0 0 0 0 0 0 0 0 0];

winde = [interp1(windh, windx, height)
         interp1(windh, windy, height)
         interp1(windh, windz, height)];
HEB   = DCM(phir, thetar, psir);
windb = HEB * winde;
end
