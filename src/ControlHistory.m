classdef ControlHistory
    properties
        Enabled
        Times
        Deltas
    end
    methods
        function obj = ControlHistory(enabled,times,deltas)
            arguments
                enabled (1,1) logical
                times (1,:) double
                deltas (:,:) double
            end
            if size(deltas,1)~=numel(times)
                error('ControlHistory:SizeMismatch','deltas must have one row per time.');
            end
            obj.Enabled=enabled; obj.Times=times; obj.Deltas=deltas;
        end
        function uTotal=totalControl(obj,t,uNominal,isRunning)
            arguments
                obj (1,1) ControlHistory
                t (1,1) double
                uNominal (:,1) double
                isRunning (1,1) logical
            end
            if obj.Enabled && isRunning
                uTotal=uNominal+interp1(obj.Times,obj.Deltas,t)';
            else
                uTotal=uNominal;
            end
        end
    end
end
