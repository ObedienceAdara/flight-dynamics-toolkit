function scenario = loadScenario(jsonPath)
%LOADSCENARIO  Load and validate a flight scenario from a JSON file.
%   scenario = LOADSCENARIO(jsonPath) reads a scenario file (see
%   config/businessjet_mach_trim.json for an example, and
%   config/README.md for the full field reference) and returns a struct
%   with everything needed to build an Aircraft, a ControlHistory, and the
%   initial condition vectors.

if ~isfile(jsonPath)
    error('loadScenario:FileNotFound', 'Scenario file not found: %s', jsonPath);
end
raw = jsondecode(fileread(jsonPath)); D2R=pi/180;
required={'aircraft','rotationMode','flightCondition','analysis','time'};
for i=1:numel(required), if ~isfield(raw,required{i}), error('loadScenario:MissingField','Scenario is missing required top-level field ''%s''.',required{i}); end, end
if ~isfield(raw.aircraft,'builder'), error('loadScenario:MissingField','scenario.aircraft.builder is required.'); end
if exist(raw.aircraft.builder,'file')~=2, error('loadScenario:UnknownBuilder','Aircraft builder function ''%s'' was not found on the path.',raw.aircraft.builder); end
scenario.AircraftBuilder=str2func(raw.aircraft.builder);
if ~ismember(raw.rotationMode,{'Euler','Quaternion'}), error('loadScenario:InvalidRotationMode','rotationMode must be ''Euler'' or ''Quaternion'' (got ''%s'').',raw.rotationMode); end
scenario.RotationMode=raw.rotationMode;
scenario.Analysis=struct('Trim',getFieldOr(raw.analysis,'trim',true),'Linearize',getFieldOr(raw.analysis,'linearize',false),'Simulate',getFieldOr(raw.analysis,'simulate',true));
scenario.TimeSpan=[getFieldOr(raw.time,'initial',0),getFieldOr(raw.time,'final',30)];
scenario.AltitudeMeters=raw.flightCondition.altitudeMeters; scenario.Mach=raw.flightCondition.mach;
ic=getFieldOr(raw,'initialConditions',struct());
scenario.InitialConditions=struct('AlphaRad',D2R*getFieldOr(ic,'alphaDeg',0),'BetaRad',D2R*getFieldOr(ic,'betaDeg',0),'AltitudeRateMps',getFieldOr(ic,'altitudeRateMps',0),'RollRateRad',D2R*getFieldOr(ic,'rollRateDegPerSec',0),'PitchRateRad',D2R*getFieldOr(ic,'pitchRateDegPerSec',0),'YawRateRad',D2R*getFieldOr(ic,'yawRateDegPerSec',0),'RollAngleRad',D2R*getFieldOr(ic,'rollAngleDeg',0),'YawAngleRad',D2R*getFieldOr(ic,'yawAngleDeg',0),'NorthPositionM',getFieldOr(ic,'northPositionM',0),'EastPositionM',getFieldOr(ic,'eastPositionM',0));
trimCfg=getFieldOr(raw,'trim',struct()); scenario.TrimInitialGuess=getFieldOr(trimCfg,'initialGuess',[-0.1,0.4,0.01]); scenario.TrimInitialGuess=scenario.TrimInitialGuess(:);
ti=getFieldOr(raw,'testInputs',struct()); scenario.TestInputs=[D2R*getFieldOr(ti,'elevatorDeg',0);D2R*getFieldOr(ti,'aileronDeg',0);D2R*getFieldOr(ti,'rudderDeg',0);getFieldOr(ti,'throttle',0);D2R*getFieldOr(ti,'asymmetricSpoilerDeg',0);D2R*getFieldOr(ti,'flapDeg',0);D2R*getFieldOr(ti,'stabilatorDeg',0)];
sp=getFieldOr(raw,'statePerturbation',struct()); scenario.StatePerturbation=[getFieldOr(sp,'u',0);getFieldOr(sp,'v',0);getFieldOr(sp,'w',0);getFieldOr(sp,'x',0);getFieldOr(sp,'y',0);getFieldOr(sp,'z',0);getFieldOr(sp,'p',0);getFieldOr(sp,'q',0);getFieldOr(sp,'r',0);D2R*getFieldOr(sp,'phiDeg',0);D2R*getFieldOr(sp,'thetaDeg',0);D2R*getFieldOr(sp,'psiDeg',0)];
ch=getFieldOr(raw,'controlHistory',struct()); enabled=getFieldOr(ch,'enabled',false); times=getFieldOr(ch,'timesSeconds',scenario.TimeSpan); times=times(:)'; deltasRaw=getFieldOr(ch,'deltas',struct([])); nRows=numel(deltasRaw); deltas=zeros(max(nRows,numel(times)),7); for i=1:nRows, d=deltasRaw(i); deltas(i,:)=[D2R*getFieldOr(d,'elevatorDeg',0),D2R*getFieldOr(d,'aileronDeg',0),D2R*getFieldOr(d,'rudderDeg',0),getFieldOr(d,'throttle',0),D2R*getFieldOr(d,'asymmetricSpoilerDeg',0),D2R*getFieldOr(d,'flapDeg',0),D2R*getFieldOr(d,'stabilatorDeg',0)]; end
scenario.ControlHistory=ControlHistory(logical(enabled),times,deltas);
end
function value=getFieldOr(s,fieldName,defaultValue)
if isstruct(s)&&isfield(s,fieldName)&&~isempty(s.(fieldName)), value=s.(fieldName); else, value=defaultValue; end
end
