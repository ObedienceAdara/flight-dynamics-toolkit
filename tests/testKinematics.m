classdef testKinematics < matlab.unittest.TestCase
    methods (Test)
        function dcmIsIdentityAtZeroAngles(testCase), testCase.verifyEqual(DCM(0,0,0),eye(3),'AbsTol',1e-12); end
        function dcmIsOrthonormal(testCase)
            A=[.3 -.2 1.1;pi/2-.01 .1 -2.5;-1 1 3;2.9 -.4 .05];
            for i=1:size(A,1), H=DCM(A(i,1),A(i,2),A(i,3)); testCase.verifyEqual(H*H',eye(3),'AbsTol',1e-10); testCase.verifyEqual(det(H),1,'AbsTol',1e-10); end
        end
        function rmqIsOrthonormal(testCase)
            Q=[0 0 0 1;.1 .2 .3 sqrt(1-.1^2-.2^2-.3^2);.5 -.5 .5 .5];
            for i=1:size(Q,1), q=Q(i,:); H=RMQ(q(1),q(2),q(3),q(4)); testCase.verifyEqual(H*H',eye(3),'AbsTol',1e-10); end
        end
        function euler2quatMatchesDCM(testCase)
            A=[.05 .1 .02;0 0 0;-.3 .5 1.2;pi/2-.01 .2 -1];
            for i=1:size(A,1), q=euler2quat(A(i,1),A(i,2),A(i,3)); testCase.verifyEqual(RMQ(q(1),q(2),q(3),q(4)),DCM(A(i,1),A(i,2),A(i,3)),'AbsTol',1e-10); end
        end
        function quat2eulerRoundTrips(testCase)
            A=[.05 .1 .02;0 0 0;-.3 .5 1.2;pi/2-.01 .2 -1];
            for i=1:size(A,1), q=euler2quat(A(i,1),A(i,2),A(i,3)); testCase.verifyEqual(quat2euler(q'),A(i,:),'AbsTol',1e-9); end
        end
        function quat2eulerHandlesTrajectory(testCase)
            A=[0 0 0;.1 .05 -.2;.4 -.3 .6]; Q=zeros(3,4); for i=1:3, Q(i,:)=euler2quat(A(i,1),A(i,2),A(i,3))'; end; testCase.verifyEqual(quat2euler(Q),A,'AbsTol',1e-9);
        end
    end
end
