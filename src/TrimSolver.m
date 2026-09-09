classdef TrimSolver < handle
    properties
        Aircraft
        ControlHistory
        BaseControl
        BaseState
        Airspeed
        History
    end
    methods
        function obj=TrimSolver(aircraft,controlHistory,baseControl,baseState,airspeed)
            arguments
                aircraft (1,1) Aircraft
                controlHistory (1,1) ControlHistory
                baseControl (7,1) double
                baseState (12,1) double
                airspeed (1,1) double
            end
            obj.Aircraft=aircraft; obj.ControlHistory=controlHistory; obj.BaseControl=baseControl; obj.BaseState=baseState; obj.Airspeed=airspeed; obj.History=zeros(4,0);
        end
        function [u,x]=controlAndState(obj,optParam)
            u0=obj.BaseControl; x0=obj.BaseState;
            u=[u0(1);u0(2);u0(3);optParam(2);u0(5);u0(6);optParam(1)];
            x=[obj.Airspeed*cos(optParam(3));x0(2);obj.Airspeed*sin(optParam(3));x0(4);x0(5);x0(6);x0(7);x0(8);x0(9);x0(10);optParam(3);x0(12)];
        end
        function J=cost(obj,optParam)
            [u,x]=obj.controlAndState(optParam);
            xdot=eomEuler(1,x,obj.Aircraft,obj.ControlHistory,u,false);
            xCost=[xdot(1);xdot(3);xdot(8)]; J=xCost'*xCost;
            obj.History(:,end+1)=[optParam(:);J];
        end
        function result=solve(obj,initialGuess,options)
            initialGuess=double(initialGuess(:));
            if numel(initialGuess)~=3, error('TrimSolver:solve:InvalidInitialGuess','initialGuess must have 3 elements.'); end
            if nargin<3 || isempty(options), options=optimset('TolX',1e-6,'TolFun',1e-10); end
            obj.History=zeros(4,0);
            [optParam,J,exitFlag,output]=fminsearch(@obj.cost,initialGuess,options);
            [uTrim,xTrim]=obj.controlAndState(optParam);
            result=struct('OptParam',optParam,'Cost',J,'ExitFlag',exitFlag,'Output',output,'ControlVector',uTrim,'StateVector',xTrim,'History',obj.History);
        end
    end
end
