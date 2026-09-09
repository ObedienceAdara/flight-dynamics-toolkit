function aircraft = buildBusinessJetMach()
%BUILDBUSINESSJETMACH  Build the Mach-dependent business jet.
%   aircraft = BUILDBUSINESSJETMACH() returns an Aircraft object with the
%   Mach-dependent, low-angle-of-attack aerodynamic model, for use with
%   FlightSimulation. This is the model matching FLIGHTv2.m's documented
%   example trim condition: 3,050 m altitude, Mach 0.3.
%
%   This is a direct, numerically-verified port of the original
%   BusinJetM.m. It differs only in returning an Aircraft object instead
%   of calling `save('MachModelData', ...)` to write a .mat file that
%   MachModel.m would later re-load on every integrator step.
%
%   Original: Copyright 2023 by Robert F. Stengel. All rights reserved.

data.ACtype = 'BusinJetM';
data.MODEL  = 'Mach';
data.mSim = 4536;
data.Ixx  = 35926.5;
data.Iyy  = 33940.7;
data.Izz  = 67085.5;
data.Ixz  = 3418.17;
data.cBar = 2.14;
data.b    = 10.4;
data.S    = 21.5;
ARw       = 5.02;
sweepw    = 13 * .01745329;
ARh       = 4;
sweeph    = 25 * .01745329;
ARv       = 0.64;
sweepv    = 40 * .01745329;
data.StaticThrust = 26243.2;
MachTable = [0 0.1 0.2 0.3 0.4 0.5 0.55 0.6 0.65 0.7 0.725 0.75 ...
             0.76 0.77 0.78 0.79 0.8 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 ...
             0.89 0.9];
MachLength = length(MachTable);
PrFac = zeros(1, MachLength);
WingMach = zeros(1, MachLength);
HorizTailMach = zeros(1, MachLength);
VertTailMach = zeros(1, MachLength);
for i = 1:MachLength
    Mach = MachTable(i);
    PrFac(i)         = 1 / (sqrt(1 - Mach^2));
    WingMach(i)      = 1 / (1 + sqrt(1 + ((ARw / (2 * cos(sweepw)))^2) ...
                        * (1 - Mach^2 * cos(sweepw))));
    HorizTailMach(i) = 1 / (1 + sqrt(1 + ((ARh / (2 * cos(sweeph)))^2) ...
                        * (1 - Mach^2 * cos(sweeph))));
    VertTailMach(i)  = 1 / (1 + sqrt(1 + ((ARv / (2 * cos(sweepv)))^2) ...
                        * (1 - Mach^2 * cos(sweepv))));
end
WingMach      = WingMach / WingMach(1);
HorizTailMach = HorizTailMach / HorizTailMach(1);
VertTailMach  = VertTailMach / VertTailMach(1);
CLTable      = 0.0747 * WingMach;
CLAlphaTable = 5.8279 * WingMach;
CLqHatTable  = 7.4838 * WingMach;
CLdETable    = 0.5774 * WingMach;
CLdFTable    = 0.859 * WingMach;
CLdSTable    = 2.5 * CLdETable;
CDTable      = 0.0254 * PrFac;
data.epsilon = 0.0718;
CDqHatTable  = zeros(1, MachLength);
CDdETable    = zeros(1, MachLength);
CDdFTable    = 0.057 * PrFac;
CDdSTable    = zeros(1, MachLength);
CmTable      = -0.0006 * HorizTailMach;
CmAlphaTable = -1.0671 * HorizTailMach;
CmqHatTable  = -15.1292 * HorizTailMach;
data.SMsim = -CmAlphaTable(1, 1) / CLAlphaTable(1, 1);
CmdETable = -1.3749 * HorizTailMach;
CmdFTable = 0.114 * HorizTailMach;
CmdSTable = 2.5 * CmdETable;
CYBetaTable = -0.6261 * VertTailMach;
CYpHatTable = zeros(1, MachLength);
CYrHatTable = zeros(1, MachLength);
CYdATable   = -0.00699 * WingMach;
CYdRTable   = 0.1574 * VertTailMach;
CYdASTable  = -0.1 * CYdATable;
ClBetaTable = -0.1649 * WingMach;
ClpHatTable = -0.8124 * WingMach;
ClrHatTable = -0.0104 * WingMach;
CldATable   = 0.1377 * WingMach;
CldRTable   = 0.0175 * WingMach;
CldASTable  = -0.1 * CldATable;
CnBetaTable = 0.1434 * VertTailMach;
CnpHatTable = 0.0104 * WingMach;
CnrHatTable = 0.0649 * VertTailMach;
CndATable   = 0.0014 * WingMach;
CndRTable   = -0.0698 * VertTailMach;
CndASTable  = -0.1 * CndATable;
data.MachTable   = MachTable;
data.MachLength  = MachLength;
data.CLTable      = CLTable;
data.CLAlphaTable = CLAlphaTable;
data.CLqHatTable  = CLqHatTable;
data.CLdETable    = CLdETable;
data.CLdFTable    = CLdFTable;
data.CLdSTable    = CLdSTable;
data.CDTable      = CDTable;
data.CDqHatTable  = CDqHatTable;
data.CDdETable    = CDdETable;
data.CDdFTable    = CDdFTable;
data.CDdSTable    = CDdSTable;
data.CmTable      = CmTable;
data.CmAlphaTable = CmAlphaTable;
data.CmqHatTable  = CmqHatTable;
data.CmdETable    = CmdETable;
data.CmdFTable    = CmdFTable;
data.CmdSTable    = CmdSTable;
data.CYBetaTable  = CYBetaTable;
data.CYpHatTable  = CYpHatTable;
data.CYrHatTable  = CYrHatTable;
data.CYdATable    = CYdATable;
data.CYdRTable    = CYdRTable;
data.CYdASTable   = CYdASTable;
data.ClBetaTable  = ClBetaTable;
data.ClpHatTable  = ClpHatTable;
data.ClrHatTable  = ClrHatTable;
data.CldATable    = CldATable;
data.CldRTable    = CldRTable;
data.CldASTable   = CldASTable;
data.CnBetaTable  = CnBetaTable;
data.CnpHatTable  = CnpHatTable;
data.CnrHatTable  = CnrHatTable;
data.CndATable    = CndATable;
data.CndRTable    = CndRTable;
data.CndASTable   = CndASTable;
aircraft = Aircraft(data);
end
