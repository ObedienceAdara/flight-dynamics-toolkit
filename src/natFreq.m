function nf = natFreq(F)
%NATFREQ Natural frequencies, damping ratios, time constants, and periods.
arguments
    F (:,:) double
end
eigenvalues=eig(F);
[~,order]=sort(real(eigenvalues),'descend'); eigenvalues=eigenvalues(order);
nf=struct('Eigenvalue',{},'IsOscillatory',{},'TimeConstant',{},'NaturalFrequency',{},'DampingRatio',{},'Period',{});
for i=1:length(eigenvalues)
    lambda=eigenvalues(i);
    if imag(lambda)==0
        Tau=-1/real(lambda); disp(['Time constant = ',num2str(Tau),' s']);
        nf(i)=struct('Eigenvalue',lambda,'IsOscillatory',false,'TimeConstant',Tau,'NaturalFrequency',NaN,'DampingRatio',NaN,'Period',NaN);
    else
        wn=sqrt(real(lambda)^2+imag(lambda)^2); zeta=-real(lambda)/wn; P=2*pi/wn;
        disp(['Natural frequency = ',num2str(wn),' rad/s',', Damping ratio = ',num2str(zeta)]); disp(['Period = ',num2str(P),' s']);
        nf(i)=struct('Eigenvalue',lambda,'IsOscillatory',true,'TimeConstant',NaN,'NaturalFrequency',wn,'DampingRatio',zeta,'Period',P);
    end
end
end
