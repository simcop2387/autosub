function  [Excitation,nnulcoef]= WRELP(Voice,Gain,error_f,WL);
% function  [Excitation,nulcoef]= WRELP(Voice,Pitch,Gain,error_f,WL);
% Do RELP based on wavelet- transform;
%
global T;

if ( Voice ==0)		% suppose that it is unvoice
   [EC,EL]=wavedec(error_f,5,'db3');
   ECn=norm(EC);				% norm;
   EC(abs(EC)<T*ECn)=0;
   nnulcoef=length(find(EC~=0));
   ECR=EC; %+randn(length(EC),1)*Gain;
   RecErr=waverec(ECR,EL,'db3');
   En=sum(abs(RecErr).^2);								% energy
   Excitation=RecErr+randn(length(RecErr),1)*Gain*0.2;	% Added some noise to that;	
else					% Suppose that it is detected as voice roughly
   [EC,EL]=wavedec(error_f,5,'db3');
	ECn=norm(EC);				% norm;
   EC(abs(EC)<T*max(EC))=0;
   nnulcoef=length(find(EC~=0));
   ECR=EC; 							 					% +randn(length(EC),1)*Gain/2;
   RecErr=waverec(ECR,EL,'db3');%+randn(length(RecErr),1)*Gain/5;
   En=sum(abs(RecErr).^2);							% energy
   Excitation=RecErr+randn(WL,1)*Gain*0.07;	% Added some noise to that;	
end

return;