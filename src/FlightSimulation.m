classdef FlightSimulation < handle
    properties
        Aircraft
        ControlHistory
        RotationMode
        TrimResult
        LinearModel
        Trajectory
    end
    methods
        function obj=FlightSimulation(aircraft,controlHistory,rotationMode)
            if nargin<3 || isempty(rotationMode), rotationMode='Euler'; end
            if ~isa(aircraft,'Aircraft') || ~isscalar(aircraft), error('FlightSimulation:InvalidAircraft','aircraft must be a scalar Aircraft object.'); end
            if ~isa(controlHistory,'ControlHistory') || ~isscalar(controlHistory), error('FlightSimulation:InvalidControlHistory','controlHistory must be a scalar ControlHistory object.'); end
            if ~ismember(rotationMode,{'Euler','Quaternion'}), error('FlightSimulation:InvalidRotationMode','rotationMode must be Euler or Quaternion.'); end
            obj.Aircraft=aircraft; obj.ControlHistory=controlHistory; obj.RotationMode=rotationMode; obj.TrimResult=[]; obj.LinearModel=[]; obj.Trajectory=[];
        end
        function result=trim(obj,u0,x0,airspeed,initialGuess,options)
            if nargin<6, options=[]; end
            solver=TrimSolver(obj.Aircraft,obj.ControlHistory,u0,x0,airspeed);
            result=solver.solve(initialGuess,options); obj.TrimResult=result;
        end
        function lin=linearize(obj)
            if isempty(obj.TrimResult), error('FlightSimulation:NotTrimmed','Call trim() before linearize().'); end
            xj0=[obj.TrimResult.StateVector;obj.TrimResult.ControlVector];
            augFun=@(tj,xj)linearize(tj,xj,obj.Aircraft,obj.ControlHistory);
            xdotj0=augFun(0,xj0); thresh=0.1*ones(19,1);
            [dFdX,~]=numjac(augFun,0,xj0,xdotj0,thresh,[],0);
            Fmodel=dFdX(1:12,1:12); Gmodel=dFdX(1:12,13:19); Lmodel=Fmodel(1:12,1:3); modes=natFreq(Fmodel);
            lin=struct('Fmodel',Fmodel,'Gmodel',Gmodel,'Lmodel',Lmodel,'Modes',modes); obj.LinearModel=lin;
        end
        function traj=simulate(obj,x0,tspan,odeOptions)
            if isempty(obj.TrimResult), error('FlightSimulation:NotTrimmed','Call trim() before simulate().'); end
            if nargin<4 || isempty(odeOptions), odeOptions=odeset('Events',@event,'RelTol',1e-10,'AbsTol',1e-10); end
            uNominal=obj.TrimResult.ControlVector;
            if strcmp(obj.RotationMode,'Euler')
                odefun=@(t,x)eomEuler(t,x,obj.Aircraft,obj.ControlHistory,uNominal,true);
            else
                odefun=@(t,x)eomQuaternion(t,x,obj.Aircraft,obj.ControlHistory,uNominal,true);
            end
            [t,x]=ode45(odefun,tspan,x0,odeOptions); traj=struct('t',t,'x',x,'rotationMode',obj.RotationMode); obj.Trajectory=traj;
        end
    end
end
