function xdotj = linearize(tj, xj, aircraft, controlHistory)
%LINEARIZE Augmented-state dynamics for Jacobian evaluation via numjac.
arguments
    tj (1,1) double
    xj (19,1) double
    aircraft (1,1) Aircraft
    controlHistory (1,1) ControlHistory
end
x=xj(1:12); u=xj(13:19);
xdot=eomEuler(tj,x,aircraft,controlHistory,u,false);
xdotj=[xdot;0;0;0;0;0;0;0];
end
