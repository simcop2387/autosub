function [Refl_coef,Aparm,error_f,error_b,Gain]=DoLPCAna(Data,POrder,Method,Drawmode,Start,WL,WT)
% function [Refl_coef,Aparm,error_f,error_b,Gain]=DoLPCAna(Data,POrder,Method,Drawmode,Start,WL,WT)
% By Yuanbin Guo for Course Project ELEC532
%
global FS;
FFTpoint = 1024;
N=length(Data);
if isempty(FS)
   FS=8000;			% For security
end

if nargin ==7
   BlkData=Data(Start:Start+WL-1);
   if strcmp(WT,'Rectrang')
      BlkData=BlkData;
      w=ones(WL,1);
   else 
      winfun=strcat(WT,'(');
      winfun=strcat(winfun,'WL');
      winfun=strcat(winfun,')');
      w=eval(winfun);		% Get the window data;
      BlkData=BlkData.*w;	% This is for pure Analysis Case. It will help to draw some graphs.
   end   
else
   Start=1;WL=length(Data);
   global WT;
   BlkData=Data; 	% in the case of LPCencoder, the Data has been preprocessed;
end

switch Method
case '1'       %'levi'
   [A, MSEP, K] = myLevinson(BlkData,POrder);
   Refl_coef = K(:,1);
   Aparm=[1 A(POrder,:)];
   error_f = filter(Aparm,1,BlkData);
   error_b=[];					% for Levinson algorithm, no backward_error;
   Gain=MSEP(POrder);
case '2' 		%'burg'
   [k,a,ef,eb,MSEP]=myburg(BlkData,POrder);
   Refl_coef = k(:,1);			% The PARCOR coeffcients
   Aparm = [1 a(POrder,:)];	% The A-par of Prediction Error Filter A(z);
   error_f= ef';
   error_b=eb;
   Gain=MSEP(POrder);   
case 'durb'	
case 'corr'
otherwise	% default 'levi'
   [A, MSEP, K] = myLevinson(BlkData,POrder);
   Refl_coef = K(:,1);
   Aparm=[1 A(POrder,:)];
   error_f = filter(Aparm,1,BlkData);
   error_b=[];					% for Levinson algorithm, no backward_error;
   Gain=MSEP(POrder);
end

switch Drawmode
case 'dr'
   % plot the Coeffecients; 
   % In the case of LPCencoder, it is recommeded not use this mode;
   % In LPC analysis, we will plot the following graphs:
   % Fig1.
   figure('Name','The signals in Time Domain!');
   
   subplot(4,1,1);plot((1:N)/FS,Data);hold on;
   title('The original Signal and windowed signal!');
   xlblstr=strcat('Time in Sec, FS=',num2str(FS));
   xlblstr=strcat(xlblstr,' Data Length=');
   xlblstr=strcat(xlblstr,num2str(N));
   xlblstr=strcat(xlblstr,' W0=');xlblstr=strcat(xlblstr,num2str(Start));
   xlblstr=strcat(xlblstr,' WL=');xlblstr=strcat(xlblstr,num2str(WL));
   xlabel(xlblstr);ylabel('Value of signal');
   Wdtmp=zeros(N,1);
   Wdtmp(Start:Start+WL-1)=w(1:WL)*max(BlkData);
   % plot the Window ;
   plot((1:N)/FS,Wdtmp,'g-.');hold on;
   Wdtmp(Start:Start+WL-1)=BlkData(1:WL);	% plot the windowed data
   plot((1:N)/FS,Wdtmp,'r--');hold on;
   
   % plot the zoomed out data;
   subplot(4,1,2);plot((1:WL)/FS+(Start)/FS,Data(Start:Start+WL-1));hold on;
   % title('The zoom out windowed data!');
   Wdtmp=zeros(WL,1);
   Wdtmp(1:WL)=w(1:WL)*max(BlkData);	% plot the Window;
   plot((Start+(1:WL))/FS,Wdtmp,'g-.');hold on;
   Wdtmp=BlkData;			% plot the windowed data
   plot((Start+(1:WL))/FS,BlkData,'r--');hold on;
   
   subplot(4,1,3);plot(error_f);
   % title('The forward prediction error');
   
   RecData=filter(1,Aparm,error_f);
   subplot(4,1,4);plot(RecData);
   % title('The reconstructed data with error_f as excitation!');
   
   figure('Name','The Spectra of these signals');
   
   PSDData=20*log10(abs(fft(Data)));		% For the whole data
   subplot(3,1,1);plot(PSDData(1:N/2));
   title('The long-term PSD of data');
   
   PSDerrf=20*log10(abs(fft(error_f,FFTpoint)));
   subplot(3,1,2);plot(PSDerrf(1:FFTpoint/2));
   title('The PSD of error_f');
   
   AF=abs(fft(Aparm,FFTpoint)).^2;
   %AModelPSDdb=10*log10(AF);
   InvModPSD=Gain./AF;
   InvModelPSDdb=10*log10(InvModPSD);
   PSDWData=abs(fft(BlkData,FFTpoint)).^2;
   PSDWDatadb=10*log10(PSDWData);
   subplot(3,1,3);plot(PSDWDatadb(1:FFTpoint/2));hold on;
   %subplot(3,1,3);plot(Aparm,'r--');
   %subplot(3,1,3);plot(AModelPSDdb(1:FFTpoint/2),'r--');
   subplot(3,1,3);plot(InvModelPSDdb(1:FFTpoint/2),'r-.');
   figure('Name','Put together');
   
   plot(PSDWDatadb(1:FFTpoint/2));hold on;
   plot(InvModelPSDdb(1:FFTpoint/2),'r-');hold on;
   plot(PSDerrf(1:FFTpoint/2),'g-.');hold on;
   grid on;legend('DataPSD','Model PSD','errorPSD');
      
   figure('Name','Analysis of The linear prediction parameters');
   subplot(4,1,1);plot(Refl_coef);
   LAR=log10((1-Refl_coef)./(1+Refl_coef));
   subplot(4,1,2);plot(LAR);
   title('LAR ');
   subplot(4,1,3);plot(MSEP);
   [Ha,Wa]=freqz(1,Aparm);
   subplot(4,1,4);z=roots(Aparm);zplane(1,z); % plot the poles 
  
   
   Hord=figure('Name','The order selection of the Linear predictor');
   for p=1:POrder
      AIC(p)= WL*log(MSEP(p))+2*p;
	   MDL(p)=WL*log(MSEP(p))+p*log(WL);
	end
   plot(AIC);hold on;
   plot(MDL,'-.');hold on;
   legend('AIC value','MDL value');
   grid on;
   
   % Draw the ACF of both BlkData and error_f;
   Rxx=xcorr(BlkData);
   Ree=xcorr(error_f);
   figure('Name','The Autocorrelation of BlkData and error_f');
   subplot(2,1,1);plot(Rxx);
   title('The ACF of BlkData');
   subplot(2,1,2);plot(Ree);
   title('The ACF of error_f');
      
   % Do the wavelet analysis of both original signal and error signal;
   % 
   [OC,OL]=wavedec(BlkData,4,'db3');
   [EC,EL]=wavedec(error_f,4,'db3');
   figure('Name','The wavedec of BlkData and error_f');
   subplot(2,2,1);plot(BlkData);
   title('The BlkData');
   subplot(2,2,2);plot(OC);
   title('The wavedec coeffs of BlkData for L4');
   subplot(2,2,3);plot(error_f);
   title('error_f');
   subplot(2,2,4);plot(EC);
   title('The wavedec coeffs of error_f');
   
   % Try the approximation of the error_f;
   % Use the wavelet to reconstruct the speech;
   figure('Name','The reconstruction of using wavelet');
   OC(OL(1):WL)=0;
   RecwBlkData=waverec(OC,OL,'db3');
   %   EC(EL(1):WL)=0;
   EC(abs(EC)<0.2*max(EC))=0;
   RecErr=waverec(EC,EL,'db3');
   RecewData=filter(1,Aparm,RecErr);
   subplot(4,1,1);plot(BlkData);legend('original data');
   subplot(4,1,2);plot(RecwBlkData);legend('RecwBlkData');
   subplot(4,1,3);plot(RecErr);legend('The recErr');
   subplot(4,1,4);plot(RecewData);legend('Synthesized from the recErr');
%    SNR=sum(RecewData).^2/sum(abs(RecewData-BlkData)).^2;
     
   figure('Name','Using wavelet to do pitch detection');
   PSDOC=abs(fft(OC,1024)).^2;
   % PSDOC=10*log10(PSDOC);
   subplot(2,1,1);plot(PSDOC(1:512));
   title('The PSD of lower OC');
   PSDEC=abs(fft(EC,1024)).^2;
   %PSDEC=PSDEC;
   subplot(2,1,2);plot(PSDEC(1:512));
   title('The PSD of lower EC');
   savefl=input('Save the current data:(Y/N)','s');
   if savefl=='Y'
      save TestFile.mat;
   end;
otherwise
   % Only get the coefficients and return;
   % This is for the LPCencoder;
	return; 
end
