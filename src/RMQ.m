function H = RMQ(q1,q2,q3,q4)
arguments
    q1 (1,1) double {mustBeReal,mustBeFinite}
    q2 (1,1) double {mustBeReal,mustBeFinite}
    q3 (1,1) double {mustBeReal,mustBeFinite}
    q4 (1,1) double {mustBeReal,mustBeFinite}
end
H=zeros(3,3); H(1,1)=q1^2-q2^2-q3^2+q4^2; H(1,2)=2*(q1*q2+q3*q4); H(1,3)=2*(q1*q3-q2*q4); H(2,1)=2*(q1*q2-q3*q4); H(2,2)=-q1^2+q2^2-q3^2+q4^2; H(2,3)=2*(q2*q3+q1*q4); H(3,1)=2*(q1*q3+q2*q4); H(3,2)=2*(q2*q3-q1*q4); H(3,3)=-q1^2-q2^2+q3^2+q4^2;
end
