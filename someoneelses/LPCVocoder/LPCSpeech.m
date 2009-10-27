function LPCSpeech
% function LPCSpeech
% A Framework for Spectrum Analysis of Speech and LPC Vocoder
% By Yuanbin Guo for Course Project ELEC 532;
% 

close all;
clear all;
global WL WT Shift PDT VDT LPT EGT;
global Data FS T;

T=0.2;

while(1)	% A simple menu here
  	
   disp('Welcome to LPC vocoder: Command Line mode');
   disp('1. Input Data from preset');
   disp('2. Input Data from command');
   disp('3. Use the previous data;');
   disp('4. Quit!');
     
   choise=input('Choose a source of input(1,2,3,4,default=parms.mat):','s');
   close all;
   switch choise
   case '1'
      %	load *.mat
      [prefile,ODir]=uigetfile('*.mat','Load a .mat file!',300,400);
      if ~isempty(prefile)
         load(prefile);
      else 
         load parms.mat
      end
   case '2'
      [WL,WT,Shift,PDT,VDT,LPT,EGT]=InputParms;
   case '3'
      if length(Data)==0
         disp('You have no previous data');
         load parms.mat		 		%default
      end
   case '4' 
      disp('Thank you for your use!Good Bye!');
      close all;
      clear all;
		return;
   otherwise		% for simple case, let it be default;
      load parms.mat
   end

	disp('The input parameters are:');
	disp('Window Length:');disp(WL);
	disp('Window Type:');disp(WT);
	disp('Window Shift:');disp(Shift);
	disp('Period Detection method:');disp(PDT);
	disp('Voiced/Unvoiced Decision method:');disp(VDT);
   disp('Linear Prediction Method:'); disp(LPT);
   
%  The second menu here!
   disp('Function selection');
   disp('1. Disp basic PSD of data;');
   disp('2. Disp Data-windowed PSD;');
   disp('3. Compute and disp the Spectrogam of data;');
   disp('4. Do LP analysis;');
   disp('5. Do LPCvocoder');
   
   choise=input('Choose a function to continue:','s');   
   switch choise
   case '1'
		figure('Name','Data-windowed Periodogram');
		N=length(Data);
      PSD=UniPSDdb(Data,1,N,WT,FS,'bs');
   case '2'
      disp('Datalength=');disp(length(Data));
      start=input('Input the start point:','s');
      start=str2num(start);
		figure('Name','Data-windowed Periodogram');
		N=length(Data);
      PSD=UniPSDdb(Data,start,WL,WT,FS,'dw');
   case '3'
      figure('Name','Spectrogram of Data');
      start=1;
      disp('Waiting for the result...');
      DoSpecgAna;
      disp('SpecgAnaEnd!');
   case '4'
      Method=LPT;
      Drawmode='dr';
      % Do LPC analysis
      Start=input('LPC from point:','s');
      Start=str2num(Start);
      % Len=input('LPC Window Length:','s');
      % Len=str2num(Len);
      POrder=input('The LP Order:','s');
      POrder=str2num(POrder);
      % Method=input('LP Method:(1.burg/2.levi)','s');     
      DoLPCAna(Data,POrder,LPT,Drawmode,Start,WL,WT);
      
   case '5' % Do LPCvocoder;
         
      LPCvocoder(WL,WT,Shift,PDT,VDT,LPT,EGT,Data,FS);
		
   otherwise % Same as the default;
      figure('Name','Data-windowed Periodogram');
		N=length(Data);
      PSD=UniPSDdb(Data,1,N,WT,FS,'bs');
   end

end

    
      



