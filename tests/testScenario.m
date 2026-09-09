classdef testScenario < matlab.unittest.TestCase
    methods (Test)
        function loadsShippedExampleScenario(testCase)
            root=fileparts(fileparts(mfilename('fullpath'))); s=loadScenario(fullfile(root,'config','businessjet_mach_trim.json')); testCase.verifyEqual(func2str(s.AircraftBuilder),'buildBusinessJetMach'); testCase.verifyEqual(s.RotationMode,'Euler'); testCase.verifyEqual(s.AltitudeMeters,3050); testCase.verifyEqual(s.Mach,.3); testCase.verifyTrue(s.Analysis.Trim); testCase.verifyFalse(s.Analysis.Linearize); testCase.verifyTrue(s.Analysis.Simulate); testCase.verifyEqual(s.TimeSpan,[0 30]); testCase.verifyEqual(s.TrimInitialGuess,[-.1;.4;.01]);
        end
        function testInputsAreConvertedToRadians(testCase)
            root=fileparts(fileparts(mfilename('fullpath'))); s=loadScenario(fullfile(root,'config','businessjet_mach_trim.json')); testCase.verifyEqual(s.TestInputs(1),-pi/180,'AbsTol',1e-12);
        end
        function missingFileThrows(testCase)
            testCase.verifyError(@()loadScenario('/nonexistent/path.json'),'loadScenario:FileNotFound');
        end
        function missingRequiredFieldThrows(testCase)
            f=[tempname(),'.json']; fid=fopen(f,'w'); fprintf(fid,'{"rotationMode":"Euler"}'); fclose(fid); c=onCleanup(@()delete(f)); testCase.verifyError(@()loadScenario(f),'loadScenario:MissingField');
        end
        function invalidRotationModeThrows(testCase)
            f=[tempname(),'.json']; fid=fopen(f,'w'); fprintf(fid,'{"aircraft":{"builder":"buildBusinessJetMach"},"rotationMode":"Bogus","flightCondition":{"altitudeMeters":100,"mach":0.1},"analysis":{},"time":{}}'); fclose(fid); c=onCleanup(@()delete(f)); testCase.verifyError(@()loadScenario(f),'loadScenario:InvalidRotationMode');
        end
    end
end
