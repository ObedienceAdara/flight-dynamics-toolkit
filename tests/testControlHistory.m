classdef testControlHistory < matlab.unittest.TestCase
    methods (Test)
        function disabledReturnsNominalRegardlessOfRunning(testCase)
            ctrl=ControlHistory(false,[0 1 2 30],zeros(4,7)); u=(1:7)'; testCase.verifyEqual(ctrl.totalControl(1.5,u,true),u); testCase.verifyEqual(ctrl.totalControl(1.5,u,false),u);
        end
        function enabledButNotRunningReturnsNominal(testCase)
            ctrl=ControlHistory(true,[0 1 2 30],ones(4,7)); u=(1:7)'; testCase.verifyEqual(ctrl.totalControl(1.5,u,false),u);
        end
        function enabledAndRunningAddsInterpolatedDelta(testCase)
            ctrl=ControlHistory(true,[0 1 2 30],[0.1 0 0 0 0 0 0;0.1 0 0 0 0 0 0;0.2 0 0 0 0 0 0;0.2 0 0 0 0 0 0]); u=ctrl.totalControl(1.5,zeros(7,1),true); testCase.verifyEqual(u(1),0.15,'AbsTol',1e-12); testCase.verifyEqual(u(2:end),zeros(6,1));
        end
        function constructorRejectsSizeMismatch(testCase)
            testCase.verifyError(@()ControlHistory(true,[0 1 2],zeros(4,7)),'ControlHistory:SizeMismatch');
        end
    end
end
