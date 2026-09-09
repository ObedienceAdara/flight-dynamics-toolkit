classdef testTrimSolver < matlab.unittest.TestCase
    methods (Test)
        function convergesAtDocumentedFlightCondition(testCase)
            aircraft=buildBusinessJetMach(); ctrl=ControlHistory(false,[0 30],zeros(2,7)); [~,~,~,a]=Atmosphere(3050); V=.3*a; s=TrimSolver(aircraft,ctrl,zeros(7,1),[V;0;0;0;0;-3050;0;0;0;0;0;0],V); r=s.solve([-.1;.4;.01]); testCase.verifyEqual(r.OptParam,[-.048561779;.18920754;.077368166],'AbsTol',1e-6); testCase.verifyLessThan(r.Cost,1e-9); testCase.verifyEqual(r.ExitFlag,1);
        end
        function historyAccumulatesOnePerEvaluation(testCase)
            a=buildBusinessJetMach(); c=ControlHistory(false,[0 30],zeros(2,7)); V=90; s=TrimSolver(a,c,zeros(7,1),[V;0;0;0;0;-3050;0;0;0;0;0;0],V); s.cost([-.1;.4;.01]); s.cost([-.05;.3;.02]); testCase.verifyEqual(size(s.History),[4 2]);
        end
        function solveResetsHistoryEachCall(testCase)
            a=buildBusinessJetMach(); c=ControlHistory(false,[0 30],zeros(2,7)); V=90; s=TrimSolver(a,c,zeros(7,1),[V;0;0;0;0;-3050;0;0;0;0;0;0],V); r1=s.solve([-.1;.4;.01]); n=size(r1.History,2); r2=s.solve([-.1;.4;.01]); testCase.verifyEqual(size(r2.History,2),n);
        end
    end
end
