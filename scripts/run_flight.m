function results = run_flight(scenarioPath)
if nargin<1 || isempty(scenarioPath)
    thisFile=mfilename('fullpath'); toolkitRoot=fileparts(fileparts(thisFile)); scenarioPath=fullfile(toolkitRoot,'config','businessjet_mach_trim.json');
end
scenario=loadScenario(scenarioPath); aircraft=scenario.AircraftBuilder(); [~,~,~,soundSpeed]=Atmosphere(scenario.AltitudeMeters); airspeed=scenario.Mach*soundSpeed; [x0,u0]=buildInitialState(scenario,airspeed);
sim=FlightSimulation(aircraft,scenario.ControlHistory,scenario.RotationMode); results=struct('Scenario',scenario,'Aircraft',aircraft,'Airspeed',airspeed);
if scenario.Analysis.Trim
    trimResult=sim.trim(u0,x0,airspeed,scenario.TrimInitialGuess); fprintf('Trim converged: cost = %.3g, exit flag = %d\n',trimResult.Cost,trimResult.ExitFlag); results.TrimResult=trimResult;
else
    sim.TrimResult=struct('StateVector',x0,'ControlVector',u0,'Cost',NaN,'ExitFlag',NaN,'OptParam',[],'Output',[],'History',zeros(4,0)); results.TrimResult=sim.TrimResult;
end
if scenario.Analysis.Linearize, results.LinearModel=sim.linearize(); end
if scenario.Analysis.Simulate
    xPerturbed=sim.TrimResult.StateVector+scenario.StatePerturbation;
    if strcmp(scenario.RotationMode,'Quaternion'), q=euler2quat(xPerturbed(10),xPerturbed(11),xPerturbed(12)); xPerturbed=[xPerturbed(1:9);q]; end
    sim.TrimResult.ControlVector=sim.TrimResult.ControlVector+scenario.TestInputs;
    trajectory=sim.simulate(xPerturbed,scenario.TimeSpan); results.Trajectory=trajectory; results.DerivedQuantities=computeFlightQuantities(trajectory,scenario.TimeSpan(2));
end
results.FlightSimulation=sim;
end
