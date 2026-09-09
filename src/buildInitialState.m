function [x0,u0]=buildInitialState(scenario,airspeed)
arguments
    scenario (1,1) struct
    airspeed (1,1) double
end
ic=scenario.InitialConditions; ze=-scenario.AltitudeMeters; phir=ic.RollAngleRad; thetar=ic.AlphaRad; psir=ic.YawAngleRad; windb=WindField(-ze,phir,thetar,psir); alphar=ic.AlphaRad; betar=ic.BetaRad;
x0=[airspeed*cos(alphar)*cos(betar)-windb(1);airspeed*sin(betar)-windb(2);airspeed*sin(alphar)*cos(betar)-windb(3);ic.NorthPositionM;ic.EastPositionM;ze;ic.RollRateRad;ic.PitchRateRad;ic.YawRateRad;phir;thetar;psir]; u0=zeros(7,1);
end
