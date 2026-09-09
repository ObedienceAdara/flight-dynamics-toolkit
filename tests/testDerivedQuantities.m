classdef testDerivedQuantities < matlab.unittest.TestCase
    methods (Test)
        function computesExpectedFields(testCase)
            t=[0;1;2]; x=[88 0 4 0 0 -3050 0 0 0 .05 .03 .01;89 .1 4.1 10 1 -3049 0 0 0 .06 .03 .01;90 .2 4.2 20 2 -3048 0 0 0 .07 .03 .01]; d=computeFlightQuantities(struct('t',t,'x',x),2); testCase.verifyEqual(numel(d.Mach),3); testCase.verifyTrue(all(d.AirspeedTAS>0)); testCase.verifyTrue(all(isfinite(d.NormalLoadFactor)));
        end
        function acceptsQuaternionTrajectory(testCase)
            t=[0;1;2]; e=[88 0 4 0 0 -3050 0 0 0 .05 .03 .01;89 .1 4.1 10 1 -3049 0 0 0 .06 .03 .01;90 .2 4.2 20 2 -3048 0 0 0 .07 .03 .01]; q=zeros(3,4); for i=1:3, q(i,:)=euler2quat(e(i,10),e(i,11),e(i,12))'; end; dq=computeFlightQuantities(struct('t',t,'x',[e(:,1:9) q]),2); de=computeFlightQuantities(struct('t',t,'x',e),2); testCase.verifyEqual(dq.Mach,de.Mach,'AbsTol',1e-9); testCase.verifyEqual(dq.AlphaDeg,de.AlphaDeg,'AbsTol',1e-9);
        end
    end
end
