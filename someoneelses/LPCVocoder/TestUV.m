%function LPCvocoder(WL,WT,Shift,PDT,VDT,LPT,EGT,Data,FS);
% function LPCvocoder()
% By Yuanbin Guo for Course Project ELEC532
%

clear all;
close all;

POrder=10;

WL=256;
Shift=256;
LPT='levi';
WT='hamming';

Lx=300;Ly=400;

%[OFlNam,ODir]=uigetfile('*.wav','Input a .wav file name for LPC encoder',Lx,Ly);
%FileNam=strcat(ODir,OFlNam);
%Postfix=OFlNam(length(OFlNam)-3:length(OFlNam));
%if strcmp(Postfix,'.wav')
%   [Data,Fs,Bits]=wavread(OFlNam);
%   figure;
%   plot(Data);
%end

%load -ascii rainspain.dat;
%Data=rainspain;
[Data,FS]=wavread('c:\532\lpcvocoder\rain8k.wav');
disp('In LPCencoder');

Framerate=Shift;

DataLen=length(Data);
blkMax=floor((DataLen-WL)/Shift); 	% Max Block Number
outSpeech=zeros(blkMax,WL);

% The data will be divided to frames with a length WL and Frameshift as Shift;
% 1																							N	 
% |_____________________________________________________________________|
% |1_____________WL|
%					|1________________WL|
%					Shift
%											...
%																	 |1________________WL|
numcoef=0;

[W,m]=GetPara_training;

for k=1:floor(blkMax)		   % Discard the last frame for simplicity					
  
   % Get the blk data 						
   blkStart=1+(k-1)*Shift;		% Start of the current Blk
   blkEnd=blkStart+WL-1;		% End of the Blk
   OBlkData=Data(blkStart:blkEnd);
   WBlkData=PreProc(OBlkData,WT,WL);	% Preprocessing the OBlkData with window;
  
   % 1. The first step, get the LPC coefficients according to method LPT;
   Drawmode = 'nd';	% do not plot the result;
   [Refl_coef,Aparm,error_f,error_b,Gain]=DoLPCAna(WBlkData,POrder,LPT,Drawmode); 
   
   Voice(k)=VUDecision(WBlkData,W,m);         % pseudo code here;
   
   indicator=k
   
end


finalSpeech=[];
for k=1:blkMax
   finalSpeech=[finalSpeech outSpeech(k,:)];
end

disp('press a key to see and listen the reconstructed speech');
pause;

subplot(2,1,1);plot(Data);
subplot(2,1,2);plot(finalSpeech);

     
   
   
   
   
   
   




