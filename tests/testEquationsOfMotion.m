classdef testEquationsOfMotion < matlab.unittest.TestCase
    properties, Aircraft, ControlHistory, end
    methods (TestMethodSetup)
        function setup(testCase)
            testCase.Aircraft=buildBusinessJetMach(); testCase.ControlHistory=ControlHistory(false,[0 30],zeros(2,7));
        end
    end
    methods (Test)
        function controlHistoryIsIgnoredWhenNotRunning(testCase)
            x=[88;0;4;0;0;-3050;0;0;0;.05;.045;0]; u=[.02;0;0;.45;0;0;-.03]; a=ControlHistory(false,[0 30],zeros(2,7)); b=ControlHistory(true,[0 30],ones(2,7)); testCase.verifyEqual(eomEuler(0,x,testCase.Aircraft,a,u,false),eomEuler(0,x,testCase.Aircraft,b,u,false),'AbsTol',1e-12);
        end
        function trimmedStateHasNearZeroLongitudinalAccelerations(testCase)
            [~,~,~,a]=Atmosphere(3050); V=.3*a; u0=zeros(7,1); x0=[V;0;0;0;0;-3050;0;0;0;0;0;0]; s=TrimSolver(testCase.Aircraft,testCase.ControlHistory,u0,x0,V); r=s.solve([-.1;.4;.01]); xd=eomEuler(1,r.StateVector,testCase.Aircraft,testCase.ControlHistory,r.ControlVector,false); testCase.verifyEqual(xd([1 3 8]),zeros(3,1),'AbsTol',1e-5);
        end
        function eulerAndQuaternionAgreeOnDerivedRates(testCase)
            x12=[88;.5;4;0;0;-3050;.01;-.02;.005;.05;.045;.02]; u=[.02;0;0;.45;0;0;-.03]; q=euler2quat(x12(10),x12(11),x12(12)); x13=[x12(1:9);q]; a=eomEuler(0,x12,testCase.Aircraft,testCase.ControlHistory,u,false); b=eomQuaternion(0,x13,testCase.Aircraft,testCase.ControlHistory,u,false); testCase.verifyEqual(b(1:9),a(1:9),'AbsTol',1e-9);
        end
    end
end
