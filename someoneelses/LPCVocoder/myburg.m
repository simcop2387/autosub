function [k,a,er_f,er_b,MSE]=myburg(s,P)
% Compute the P-order LPC coefcients via
% Lattice-burg algorithm;
% By Yuanbin Guo
% March.26th.2000.

N=length(s);

a=zeros(P,P);
k=zeros(P,1);
MSE=zeros(P+1,1);

MSE(1)=s'*s/N;

complexity=1; 				% To calculate the computing complexity;

ef=zeros(P+1,N);	eb=zeros(P+1,N);

% (1).Initialize the ef(1,:)=eb(1,:)=s(1:N);
ef(1,1:N)=s(1:N)';
eb(1,1:N)=s(1:N)';

% k(1)=
nef=sum(ef(1,2:N).*ef(1,2:N));	neb=sum(eb(1,1:N-1).*eb(1,1:N-1));
norm=nef+neb;
k(1)=-2*sum(ef(1,2:N).*eb(1,1:N-1))/norm;		%complexity=N;
a(1,1)=k(1);		

MSE(2)=(1-k(1)*k(1))*MSE(1);
% compute the ef(2,n)=ef(2,n)+k(1)*eb(1,n-1)---n:1-N;
%						eb(2,n)=eb(1,n-1)+k(1)*ef(1,n);
ef(2,1)=ef(1,1);
ef(2,2:N)=ef(1,2:N)+k(1)*eb(1,1:N-1);

eb(2,1)=k(1)*ef(1,1);
eb(2,2:N)=eb(1,1:N-1)+conj(k(1))*ef(1,2:N);

% Iterate to compute the p=2:Pth orders LPC pars;
for p=2:P
   nef=sum(ef(p,p+1:N).*ef(p,p+1:N));		neb=sum(eb(p,p:N-1).*eb(p,p:N-1));
   norm=(nef+neb)/2;
   k(p)=-sum(ef(p,p+1:N).*eb(p,p:N-1))/norm;		%complexity=complexity+N;
      
   a(p,p)=k(p);
   
   % compute a(p,2:p)
   a(p,1:p-1)=a(p-1,1:p-1)+k(p)*a(p-1,p-1:-1:1);		%complexity=complexity+1;
      
   % compute ef(p+1,n)=ef(p,n)+k(p)*eb(p,n-1);
   % 			  eb(p+1,n)=eb(p,n-1)+k(p)*ef(p,n);
   ef(p+1,1)=ef(p,1);
   ef(p+1,2:N)=ef(p,2:N)+k(p)*eb(p,1:N-1);
   
   eb(p+1,1)=-k(p)*ef(p,1);
   eb(p+1,2:N)=eb(p,1:N-1)+k(p)*ef(p,2:N);
   MSE(p+1)=(1-k(p)*k(p))*MSE(p);
end

er_f=ef(P+1,:);
er_b=eb(P+1,:);
   
   
   







