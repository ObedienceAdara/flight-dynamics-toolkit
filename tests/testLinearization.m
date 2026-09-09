classdef testLinearization < matlab.unittest.TestCase
    methods (Test)
        function linearizeMatchesDirectEomCall(testCase)
            aircraft=buildBusinessJetMach(); ctrl=ControlHistory(false,[0 30],zeros(2,7)); x=[88;0;4;0;0;-3050;0;0;0;.05;.045;0]; u=[.02;0;0;.45;0;0;-.03]; a=eomEuler(0,x,aircraft,ctrl,u,false); b=linearize(0,[x;u],aircraft,ctrl); testCase.verifyEqual(b(1:12),a,'AbsTol',1e-12); testCase.verifyEqual(b(13:19),zeros(7,1));
        end
        function natFreqSortsModes(testCase)
            F=[-.02 1 0 -9.8;-.001 -.5 1 0;.0005 -2 -1 0;0 0 1 0]; m=natFreq(F); testCase.verifyEqual(numel(m),4); rp=real([m.Eigenvalue]); testCase.verifyTrue(all(diff(rp)<=1e-12));
        end
        function natFreqHandlesRealMode(testCase), m=natFreq(-.05); testCase.verifyFalse(m.IsOscillatory); testCase.verifyEqual(m.TimeConstant,20,'AbsTol',1e-9); end
    end
end
