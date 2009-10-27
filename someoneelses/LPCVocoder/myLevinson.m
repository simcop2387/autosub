
function [A, MSEP, K] = myLevinson(x,P)
% Input : x-- The input time series x
% 				 P-- The order of LP 
% Output:
%				A -- The A parameters;
%				MSE -- The MSE in each recursion;
%				K	-- The reflection coefficients in each recursion;

N=length(x);

R=xcorr(x);
R=R(N:2*N-1);	% shift it to make it R(0)-R(N-1);

% To compute the p-order prediction, we only need R(0)-R(p);


Apar=zeros(P,P);	% To store the A parameters in each recursion;
MSEp=zeros(P);			% To store the MSE(Rou(f,p)) in each recursion;
Kpar=zeros(P);		% To store the PARCOR coef in each recursion;

%compute the initializations
Apar(1,1)=-R(2)/R(1);
MSE(1)=R(1)-R(2)^2/R(1);
Kpar(1)=Apar(1,1);
%loop to compute the parameters in 2--> P orders;
for p=1:P-1
   Deltap=R(p+2);
   for m=1:p
      Deltap=Deltap+Apar(p,m)*R(p+2-m);
   end
   Kpar(p+1)=-Deltap/MSE(p);
   for m=1:p
      Apar(p+1,m)=Apar(p,m)+Kpar(p+1)*Apar(p,p+1-m);
   end
   Apar(p+1,p+1)=Kpar(p+1);
   MSE(p+1)=MSE(p)*(1-Kpar(p+1)^2);
end

A=Apar; 	 % A P*P matrix;
MSEP=MSE; % 1*P vector;
K=Kpar;	 % 1*P vector;

% [A1,E1,K1]=levinson(R,P); % Here for debuging;
return;







   







