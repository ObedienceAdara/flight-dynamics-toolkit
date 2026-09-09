classdef testFlightSimulation < matlab.unittest.TestCase
    methods (Test)
        function constructorValidatesInputs(testCase)
            a=buildBusinessJetMach(); c=ControlHistory(false,[0 30],zeros(2,7)); testCase.verifyError(@()FlightSimulation(1,c,'Euler'),'FlightSimulation:InvalidAircraft'); testCase.verifyError(@()FlightSimulation(a,1,'Euler'),'FlightSimulation:InvalidControlHistory'); testCase.verifyError(@()FlightSimulation(a,c,'Bogus'),'FlightSimulation:InvalidRotationMode');
        end
        function linearizeRequiresTrimFirst(testCase)
            s=FlightSimulation(buildBusinessJetMach(),ControlHistory(false,[0 30],zeros(2,7)),'Euler'); testCase.verifyError(@()s.linearize(),'FlightSimulation:NotTrimmed');
        end
        function simulateRequiresTrimFirst(testCase)
            s=FlightSimulation(buildBusinessJetMach(),ControlHistory(false,[0 30],zeros(2,7)),'Euler'); testCase.verifyError(@()s.simulate(zeros(12,1),[0 10]),'FlightSimulation:NotTrimmed');
        end
        function trimThenSimulate(testCase)
            a=buildBusinessJetMach(); c=ControlHistory(true,[0 1 2 30],zeros(4,7)); [~,~,~,ss]=Atmosphere(3050); V=.3*ss; x0=[V;0;0;0;0;-3050;0;0;0;0;0;0]; s=FlightSimulation(a,c,'Euler'); r=s.trim(zeros(7,1),x0,V,[-.1;.4;.01]); s.TrimResult.ControlVector=r.ControlVector+[-pi/180;0;0;0;0;0;0]; tr=s.simulate(r.StateVector,[0 30]); testCase.verifyEqual(numel(tr.t),1601); testCase.verifyEqual(tr.t(end),30,'AbsTol',1e-9);
        end
    end
end
