classdef testAircraft < matlab.unittest.TestCase
    methods (Test)
        function machBuilderProducesValidAircraft(testCase)
            ac=buildBusinessJetMach(); testCase.verifyEqual(ac.ACtype,'BusinJetM'); testCase.verifyEqual(ac.Model,'Mach'); testCase.verifyEqual(ac.Mass,4536); testCase.verifyGreaterThan(ac.StaticMargin,0);
        end
        function alphaBuilderProducesValidAircraft(testCase)
            ac=buildBusinessJetAlpha(); testCase.verifyEqual(ac.ACtype,'BusinJetA'); testCase.verifyEqual(ac.Model,'Alph'); testCase.verifyEqual(ac.Mass,4536);
        end
        function constructorRejectsMissingFields(testCase)
            testCase.verifyError(@()Aircraft(struct('ACtype','Test','MODEL','Mach')),'Aircraft:MissingField');
        end
        function constructorRejectsUnknownModel(testCase)
            d=struct('ACtype','Test','MODEL','Bogus','mSim',1,'Ixx',1,'Iyy',1,'Izz',1,'Ixz',0,'S',1,'b',1,'cBar',1,'SMsim',.1,'StaticThrust',1000,'epsilon',.05); testCase.verifyError(@()Aircraft(d),'Aircraft:UnknownModel');
        end
        function aeroCoefficientsAreFiniteAcrossFlightEnvelope(testCase)
            ac=buildBusinessJetMach(); xs={[50;0;5;0;0;-3050;.01;.02;.005;.05;.1;.02],[80;2;-3;0;0;-1000;0;0;0;0;0;0],[30;-1;8;0;0;-500;-.02;.01;-.01;-.1;.3;0]}; us={[.01;.005;-.002;.5;0;0;-.03],[0;0;0;.6;.1;.2;.01],[-.01;-.01;.01;.3;0;-.1;.02]};
            for i=1:numel(xs), x=xs{i}; u=us{i}; V=norm(x(1:3)); a=atan(x(3)/abs(x(1))); b=asin(x(2)/V); [CD,CL,CY,Cl,Cm,Cn,T]=ac.aeroCoefficients(x,u,a,b,V); vals=[CD,CL,CY,Cl,Cm,Cn,T]; testCase.verifyTrue(all(isfinite(vals))); testCase.verifyGreaterThan(CD,0); end
        end
    end
end
