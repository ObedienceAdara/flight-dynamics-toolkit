classdef Aircraft
    %AIRCRAFT  Immutable aircraft model: mass, geometry, and aerodynamics.
    properties
        ACtype
        Model
        Mass
        Ixx
        Iyy
        Izz
        Ixz
        WingArea
        WingSpan
        MeanChord
        StaticMargin
        StaticThrust
        InducedDragFactor
        Aero
    end

    methods
        function obj = Aircraft(data)
            arguments
                data (1, 1) struct
            end
            required = {'ACtype', 'MODEL', 'mSim', 'Ixx', 'Iyy', 'Izz', 'Ixz', ...
                        'S', 'b', 'cBar', 'SMsim', 'StaticThrust', 'epsilon'};
            for i = 1:numel(required)
                if ~isfield(data, required{i})
                    error('Aircraft:MissingField', ...
                        'Aircraft data struct is missing required field ''%s''.', ...
                        required{i});
                end
            end
            if ~ismember(data.MODEL, {'Alph', 'Mach'})
                error('Aircraft:UnknownModel', ...
                    'MODEL must be ''Alph'' or ''Mach'' (got ''%s'').', data.MODEL);
            end
            obj.ACtype            = data.ACtype;
            obj.Model             = data.MODEL;
            obj.Mass              = data.mSim;
            obj.Ixx               = data.Ixx;
            obj.Iyy               = data.Iyy;
            obj.Izz               = data.Izz;
            obj.Ixz               = data.Ixz;
            obj.WingArea          = data.S;
            obj.WingSpan          = data.b;
            obj.MeanChord         = data.cBar;
            obj.StaticMargin      = data.SMsim;
            obj.StaticThrust      = data.StaticThrust;
            obj.InducedDragFactor = data.epsilon;
            aero = data;
            for i = 1:numel(required)
                aero = rmfield(aero, required{i});
            end
            obj.Aero = aero;
        end

        function [CD, CL, CY, Cl, Cm, Cn, Thrust] = aeroCoefficients(obj, x, u, alphar, betar, V)
            arguments
                obj    (1, 1) Aircraft
                x      (:, 1) double
                u      (:, 1) double
                alphar (1, 1) double
                betar  (1, 1) double
                V      (1, 1) double
            end
            switch obj.Model
                case 'Alph'
                    [CD, CL, CY, Cl, Cm, Cn, Thrust] = obj.aeroCoefficientsAlpha(x, u, alphar, betar, V);
                case 'Mach'
                    [CD, CL, CY, Cl, Cm, Cn, Thrust] = obj.aeroCoefficientsMach(x, u, alphar, betar, V);
            end
        end
    end

    methods (Access = private)
        function [CD, CL, CY, Cl, Cm, Cn, Thrust] = aeroCoefficientsAlpha(obj, x, u, alphar, betar, V)
            T = obj.Aero;
            cBar = obj.MeanChord;
            b = obj.WingSpan;
            SMsim = obj.StaticMargin;
            epsilon = obj.InducedDragFactor;
            [airDens, ~, ~, ~] = Atmosphere(-x(6));
            Thrust = u(4) * obj.StaticThrust * (airDens / 1.225)^0.7 ...
                     * (1 - exp((-x(6) - 17000) / 2000));
            alphadeg = alphar * 180 / pi;
            CLstat = interp1(T.AlphaTable, T.CLTable, alphadeg);
            CLq = interp1(T.AlphaTable, T.CLqHatTable, alphadeg) * cBar / (2 * V);
            CLdE = interp1(T.AlphaTable, T.CLdETable, alphadeg);
            CLdF = interp1(T.AlphaTable, T.CLdFTable, alphadeg);
            CLdS = interp1(T.AlphaTable, T.CLdSTable, alphadeg);
            CL = CLstat + CLq * x(8) + CLdE * u(1) + CLdF * u(6) + CLdS * u(7);
            CDo = interp1(T.AlphaTable, T.CDTable, alphadeg);
            CDq = interp1(T.AlphaTable, T.CDqHatTable, alphadeg) * cBar / (2 * V);
            CDdE = interp1(T.AlphaTable, T.CDdETable, alphadeg);
            CDdF = interp1(T.AlphaTable, T.CDdFTable, alphadeg);
            CDdS = interp1(T.AlphaTable, T.CDdSTable, alphadeg);
            CD = CDo + epsilon * CL^2 + CDq * x(8) + CDdE * u(1) + CDdF * u(6) + CDdS * u(7);
            CmStat = interp1(T.AlphaTable, T.CmTable, alphadeg);
            Cmq = interp1(T.AlphaTable, T.CmqHatTable, alphadeg) * cBar / (2 * V);
            CmdE = interp1(T.AlphaTable, T.CmdETable, alphadeg);
            CmdF = interp1(T.AlphaTable, T.CmdFTable, alphadeg);
            CmdS = interp1(T.AlphaTable, T.CmdSTable, alphadeg);
            Cm = CmStat - CL * SMsim + Cmq * x(8) + CmdE * u(1) + CmdF * u(6) + CmdS * u(7);
            CYbeta = interp1(T.AlphaTable, T.CYBetaTable, alphadeg);
            CYp = interp1(T.AlphaTable, T.CYpHatTable, alphadeg) * b / (2 * V);
            CYr = interp1(T.AlphaTable, T.CYrHatTable, alphadeg) * b / (2 * V);
            CYdA = interp1(T.AlphaTable, T.CYdATable, alphadeg);
            CYdR = interp1(T.AlphaTable, T.CYdRTable, alphadeg);
            CYdAS = interp1(T.AlphaTable, T.CYdASTable, alphadeg);
            CY = CYbeta * betar + CYp * x(7) + CYr * x(9) + CYdA * u(2) + CYdR * u(3) + CYdAS * u(5);
            Clbeta = interp1(T.AlphaTable, T.ClBetaTable, alphadeg);
            Clp = interp1(T.AlphaTable, T.ClpHatTable, alphadeg) * b / (2 * V);
            Clr = interp1(T.AlphaTable, T.ClrHatTable, alphadeg) * b / (2 * V);
            CldA = interp1(T.AlphaTable, T.CldATable, alphadeg);
            CldR = interp1(T.AlphaTable, T.CldRTable, alphadeg);
            CldAS = interp1(T.AlphaTable, T.CYdASTable, alphadeg);
            Cl = Clbeta * betar + Clr * x(9) + Clp * x(7) + (CldA * u(2) + CldR * u(3) + CldAS * u(5));
            Cnbeta = interp1(T.AlphaTable, T.CnBetaTable, alphadeg);
            Cnp = interp1(T.AlphaTable, T.CnpHatTable, alphadeg) * b / (2 * V);
            Cnr = interp1(T.AlphaTable, T.CnrHatTable, alphadeg) * b / (2 * V);
            CndA = interp1(T.AlphaTable, T.CndATable, alphadeg);
            CndR = interp1(T.AlphaTable, T.CndRTable, alphadeg);
            CndAS = interp1(T.AlphaTable, T.CndASTable, alphadeg);
            Cn = Cnbeta * betar + Cnp * x(7) + Cnr * x(9) + (CndA * u(2) + CndR * u(3) + CndAS * u(5));
        end

        function [CD, CL, CY, Cl, Cm, Cn, Thrust] = aeroCoefficientsMach(obj, x, u, alphar, betar, V)
            T = obj.Aero;
            cBar = obj.MeanChord;
            b = obj.WingSpan;
            SMsim = obj.StaticMargin;
            epsilon = obj.InducedDragFactor;
            [airDens, ~, ~, soundSpeed] = Atmosphere(-x(6));
            Thrust = u(4) * obj.StaticThrust * (airDens / 1.225)^0.7 ...
                     * (1 - exp((-x(6) - 17000) / 2000));
            Mach = V / soundSpeed;
            CLStat = interp1(T.MachTable, T.CLTable, Mach);
            CLAlpha = interp1(T.MachTable, T.CLAlphaTable, Mach);
            CLq = interp1(T.MachTable, T.CLqHatTable, Mach) * cBar / (2 * V);
            CLdE = interp1(T.MachTable, T.CLdETable, Mach);
            CLdF = interp1(T.MachTable, T.CLdFTable, Mach);
            CLdS = interp1(T.MachTable, T.CLdSTable, Mach);
            CL = CLStat + CLAlpha * alphar + CLq * x(8) + CLdE * u(1) + CLdF * u(6) + CLdS * u(7);
            CDStat = interp1(T.MachTable, T.CDTable, Mach);
            CDq = interp1(T.MachTable, T.CDqHatTable, Mach) * cBar / (2 * V);
            CDdE = interp1(T.MachTable, T.CDdETable, Mach);
            CDdF = interp1(T.MachTable, T.CDdFTable, Mach);
            CDdS = interp1(T.MachTable, T.CDdSTable, Mach);
            CD = CDStat + epsilon * CL^2 + CDq * x(8) + CDdE * u(1) + CDdF * u(6) + CDdS * u(7);
            CmStat = interp1(T.MachTable, T.CmTable, Mach);
            CmAlpha = interp1(T.MachTable, T.CmAlphaTable, Mach);
            Cmq = interp1(T.MachTable, T.CmqHatTable, Mach) * cBar / (2 * V);
            CmdE = interp1(T.MachTable, T.CmdETable, Mach);
            CmdF = interp1(T.MachTable, T.CmdFTable, Mach);
            CmdS = interp1(T.MachTable, T.CmdSTable, Mach);
            Cm = CmStat + CmAlpha * alphar - CL * SMsim + Cmq * x(8) + CmdE * u(1) + CmdF * u(6) + CmdS * u(7);
            CYBeta = interp1(T.MachTable, T.CYBetaTable, Mach);
            CYp = interp1(T.MachTable, T.CYpHatTable, Mach) * b / (2 * V);
            CYr = interp1(T.MachTable, T.CYrHatTable, Mach) * b / (2 * V);
            CYdA = interp1(T.MachTable, T.CYdATable, Mach);
            CYdR = interp1(T.MachTable, T.CYdRTable, Mach);
            CYdAS = interp1(T.MachTable, T.CYdASTable, Mach);
            CY = CYBeta * betar + CYp * x(7) + CYr * x(9) + CYdA * u(2) + CYdR * u(3) + CYdAS * u(5);
            ClBeta = interp1(T.MachTable, T.ClBetaTable, Mach);
            Clp = interp1(T.MachTable, T.ClpHatTable, Mach) * b / (2 * V);
            Clr = interp1(T.MachTable, T.ClrHatTable, Mach) * b / (2 * V);
            CldA = interp1(T.MachTable, T.CldATable, Mach);
            CldR = interp1(T.MachTable, T.CldRTable, Mach);
            CldAS = interp1(T.MachTable, T.CldASTable, Mach);
            Cl = ClBeta * betar + Clp * x(7) + Clr * x(9) + CldA * u(2) + CldR * u(3) + CldAS * u(5);
            CnBeta = interp1(T.MachTable, T.CnBetaTable, Mach);
            Cnp = interp1(T.MachTable, T.CnpHatTable, Mach) * b / (2 * V);
            Cnr = interp1(T.MachTable, T.CnrHatTable, Mach) * b / (2 * V);
            CndA = interp1(T.MachTable, T.CndATable, Mach);
            CndR = interp1(T.MachTable, T.CndRTable, Mach);
            CndAS = interp1(T.MachTable, T.CndASTable, Mach);
            Cn = CnBeta * betar + Cnp * x(7) + Cnr * x(9) + CndA * u(2) + CndR * u(3) + CndAS * u(5);
        end
    end
end
