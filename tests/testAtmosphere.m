classdef testAtmosphere < matlab.unittest.TestCase
    methods (Test)
        function seaLevelValuesAreStandard(testCase)
            [dens,pres,temp,a]=Atmosphere(0); testCase.verifyEqual(dens,1.225,'AbsTol',1e-6); testCase.verifyEqual(pres,101300,'AbsTol',1); testCase.verifyEqual(temp,288.15,'AbsTol',1e-6); testCase.verifyEqual(a,340.294,'AbsTol',1e-3);
        end
        function densityDecreasesMonotonicallyWithAltitude(testCase)
            alts=[-1000,0,2500,5000,10000,11100,15000,20000,47400,51000]; dens=zeros(size(alts)); for i=1:numel(alts), dens(i)=Atmosphere(alts(i)); end; testCase.verifyTrue(all(diff(dens)<0));
        end
        function altitudeOutOfRangeThrows(testCase)
            testCase.verifyError(@()Atmosphere(-2000),'Atmosphere:AltitudeOutOfRange'); testCase.verifyError(@()Atmosphere(60000),'Atmosphere:AltitudeOutOfRange');
        end
        function matchesKnownDocumentedCondition(testCase)
            [~,~,~,a]=Atmosphere(3050); testCase.verifyEqual(a,328.358239,'AbsTol',1e-3);
        end
    end
end
