function [FileName,Data,FS]=OpenFile

Lx=300;Ly=400;

%OFlNam=zeros(1,4);

[OFlNam,ODir]=uigetfile('*.wav','Input a .wav file name for LPC encoder',Lx,Ly);
FileNam=strcat(ODir,OFlNam);
Postfix=OFlNam(length(OFlNam)-3:length(OFlNam));
if strcmp(Postfix,'.wav')
   [Data,Fs,Bits]=wavread(OFlNam);
   figure;
   plot(Data);
else 
   %load OFlNam;
   % Not a .wav file;
end

%LPCmain('FileOpened');


