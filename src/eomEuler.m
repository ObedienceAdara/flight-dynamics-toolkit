function xdot = eomEuler(t, x, aircraft, controlHistory, uNominal, isRunning)
%EOMEULER  Euler-angle 6-DOF equations of motion.
arguments
    t              (1, 1) double
    x              (12, 1) double
    aircraft       (1, 1) Aircraft
    controlHistory (1, 1) ControlHistory
    uNominal       (7, 1) double
    isRunning      (1, 1) logical
end
HEB = DCM(x(10), x(11), x(12));
x(6) = min(x(6), 0);
[airDens, ~, ~, ~] = Atmosphere(-x(6));
windb = WindField(-x(6), x(10), x(11), x(12));
gb = HEB * [0; 0; 9.80665];
x(1) = max(x(1), 0);
Va = [x(1); x(2); x(3)] + windb;
V = sqrt(Va' * Va);
alphar = atan(Va(3) / abs(Va(1)));
betar = asin(Va(2) / V);
uTotal = controlHistory.totalControl(t, uNominal, isRunning);
[CD, CL, CY, Cl, Cm, Cn, Thrust] = aircraft.aeroCoefficients(x, uTotal, alphar, betar, V);
qbarS = 0.5 * airDens * V^2 * aircraft.WingArea;
CX = -CD * cos(alphar) + CL * sin(alphar);
CZ = -CD * sin(alphar) - CL * cos(alphar);
Xb = (CX * qbarS + Thrust) / aircraft.Mass;
Yb = CY * qbarS / aircraft.Mass;
Zb = CZ * qbarS / aircraft.Mass;
Lb = Cl * qbarS * aircraft.WingSpan;
Mb = Cm * qbarS * aircraft.MeanChord;
Nb = Cn * qbarS * aircraft.WingSpan;
xd1 = Xb + gb(1) + x(9) * x(2) - x(8) * x(3);
xd2 = Yb + gb(2) - x(9) * x(1) + x(7) * x(3);
xd3 = Zb + gb(3) + x(8) * x(1) - x(7) * x(2);
y = HEB' * [x(1); x(2); x(3)];
xd4 = y(1); xd5 = y(2); xd6 = y(3);
Ixx = aircraft.Ixx; Iyy = aircraft.Iyy; Izz = aircraft.Izz; Ixz = aircraft.Ixz;
xd7 = (Izz * Lb + Ixz * Nb - (Ixz * (Iyy - Ixx - Izz) * x(7) + ...
      (Ixz^2 + Izz * (Izz - Iyy)) * x(9)) * x(8)) / (Ixx * Izz - Ixz^2);
xd8 = (Mb - (Ixx - Izz) * x(7) * x(9) - Ixz * (x(7)^2 - x(9)^2)) / Iyy;
xd9 = (Ixz * Lb + Ixx * Nb + (Ixz * (Iyy - Ixx - Izz) * x(9) + ...
      (Ixz^2 + Ixx * (Ixx - Iyy)) * x(7)) * x(8)) / (Ixx * Izz - Ixz^2);
cosPitch = cos(x(11));
if abs(cosPitch) <= 0.00001
    cosPitch = 0.00001 * sign(cosPitch);
end
tanPitch = sin(x(11)) / cosPitch;
xd10 = x(7) + (sin(x(10)) * x(8) + cos(x(10)) * x(9)) * tanPitch;
xd11 = cos(x(10)) * x(8) - sin(x(10)) * x(9);
xd12 = (sin(x(10)) * x(8) + cos(x(10)) * x(9)) / cosPitch;
xdot = [xd1; xd2; xd3; xd4; xd5; xd6; xd7; xd8; xd9; xd10; xd11; xd12];
end
