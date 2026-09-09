function derived = computeFlightQuantities(trajectory, tf)
arguments
    trajectory (1,1) struct
    tf (1,1) double
end
t=trajectory.t; x=trajectory.x;
if size(x,2)==13
    euler=quat2euler(x(:,10:13)); x=[x(:,1:9),euler];
end
R2D=180/pi; go=9.80665; kHis=numel(t);
windBody=zeros(3,kHis); airDensHis=zeros(1,kHis); soundSpeedHis=zeros(1,kHis);
for i=1:kHis
    windBody(:,i)=WindField(-x(i,6),x(i,10),x(i,11),x(i,12));
    [airDensHis(i),~,~,soundSpeedHis(i)]=Atmosphere(-x(i,6));
end
vBody=[x(:,1) x(:,2) x(:,3)]'; vBodyAir=vBody+windBody;
AlphaAR=zeros(1,kHis); BetaAR=zeros(1,kHis); GammaHis=zeros(1,kHis); XiHis=zeros(1,kHis); VAirRel=zeros(1,kHis); vEarth=zeros(3,kHis);
for i=1:kHis
    vE=DCM(x(i,10),x(i,11),x(i,12))'*vBody(:,i); VER=sqrt(vE(1)^2+vE(2)^2+vE(3)^2); VAR=sqrt(vBodyAir(1,i)^2+vBodyAir(2,i)^2+vBodyAir(3,i)^2); VARB=sqrt(vBodyAir(1,i)^2+vBodyAir(3,i)^2);
    if vBodyAir(1,i)>=0, Alphar=asin(vBodyAir(3,i)/VARB); else, Alphar=pi-asin(vBodyAir(3,i)/VARB); end
    AlphaAR(i)=Alphar; BetaAR(i)=asin(vBodyAir(2,i)/VAR); vEarth(:,i)=vE;
    Xir=asin(vEarth(2,i)/sqrt(vEarth(1,i)^2+vEarth(2,i)^2));
    if vEarth(1,i)<=0 && vEarth(2,i)<=0, Xir=-pi-Xir; end
    if vEarth(1,i)<=0 && vEarth(2,i)>=0, Xir=pi-Xir; end
    GammaHis(i)=asin(-vEarth(3,i)/VER); XiHis(i)=Xir; VAirRel(i)=VAR;
end
MachHis=VAirRel./soundSpeedHis; qbarHis=0.5*airDensHis.*VAirRel.*VAirRel;
AlphaDegHis=R2D*AlphaAR; BetaDegHis=R2D*BetaAR; GammaDegHis=R2D*GammaHis; XiDegHis=R2D*XiHis;
Vo=zeros(1,kHis); nz=zeros(1,kHis); lastLoopIndex=1;
for i=2:kHis-1
    Vo(i)=sqrt(x(i,1)^2+x(i,2)^2+x(i,3)^2);
    nz(i)=((x(i+1,3)-x(i-1,3))/(t(i+1)-t(i-1))-Vo(i)*x(i,8))/go;
    lastLoopIndex=i;
end
nz(1)=((x(2,3)-x(1,3))/(t(2)-t(1))-Vo(lastLoopIndex)*x(1,8))/go;
nz(kHis)=((x(kHis,3)-x(kHis-1,3))/(tf-t(kHis-1))-Vo(lastLoopIndex)*x(lastLoopIndex,8))/go;
derived=struct('AirspeedTAS',VAirRel,'Mach',MachHis,'AlphaDeg',AlphaDegHis,'BetaDeg',BetaDegHis,'DynamicPressure',qbarHis,'FlightPathAngleDeg',GammaDegHis,'HeadingAngleDeg',XiDegHis,'NormalLoadFactor',-nz);
end
