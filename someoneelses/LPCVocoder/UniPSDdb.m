function PSD = UniPSDdb(x,N0,NW,WT,FS,app)
% Function PSD = UniPSDdb(x,NW,WT,FS,appr)
% A function to compute the PSD universally according to the approach par.
% Currently support the following Spectral analysis methods.
% 1: app = 'bs'---basic Periodogram;
% 2: 		  'dw'---data-windowed using the NW(Length of window and WT(window type);
% 3: 		  'lw'---lag-windowed;
% 4:		  'av'---averaged;
% 5:		  'comb'--combined;
% 6:		  'pd'---periodogram;
% The PSD is computed as Db in frequency.

N = length(x);	

switch app
case 'bs'
   X=fft(x,FS)/N;	% Using the FS as sampling rate;
   PSD=20*log10(abs(X).^2);
   PSD=PSD(1:FS/2);  
   figure('Name','Basic Periodogram');
   XAis=(1:N)/FS;
   subplot(2,1,1);plot(XAis, x);
   title('The Original Signal');
   xl=strcat('time in sec, FS=',num2str(FS));
   xlabel(xl);ylabel('Value of x');
   subplot(2,1,2);plot(PSD);
   xlabel('Frequency in Hz');ylabel('PSD in Db');
   title('The PSD in db of basic periodogram');
case 'dw'
   %  figure('Name','Data-windowed Periodogram');
   if strcmp(WT,'Rectrang')
      w=ones(NW,1);
   else 
	   winfun=strcat(WT,'(');
   	winfun=strcat(winfun,'NW');
	   winfun=strcat(winfun,')');
      w=eval(winfun);
   end
   
   w=[zeros(1,N0-1) w' zeros(1,N-NW-N0+1)]';
   subplot(2,1,1);plot((1:N)/FS,x);hold on;
   x=x.*w;
   X=fft(x,FS)/NW;
   PSD=20*log10(abs(X).^2);
   PSD=PSD(1:FS/2); 
   XAis=(1:N)/FS;
   subplot(2,1,1);plot(XAis, x,'r-.',XAis,w*max(x),'g:');hold on;
   titlename=strcat('The windowed-data with ',WT);
   titlename=strcat(titlename,' window');
   title(titlename);
   xl=strcat('time in sec, FS=',num2str(FS));
   xlabel(xl);ylabel('Value of xw');
   subplot(2,1,2);plot(PSD);hold on;
   xlabel('Frequency in Hz');ylabel('PSD in Db');       
   title('The PSD of windowed-data');
   break;
end
  

