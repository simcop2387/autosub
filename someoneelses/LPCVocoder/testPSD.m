function testPSD
close all;
clear all;

[x,FS,BITS]=wavread('Applause.wav');
NW=length(x);
N=length(x);
PSDbs=UniPSDdb(x,1,NW/2,'hanning',FS,'bs');
figure('Name','Data-windowed Periodogram');
PSDbs=UniPSDdb(x,128,NW/2,'hanning',FS,'dw');hold on;
figure;
PSDbs=UniPSDdb(x,NW/2,NW/2,'hamming',FS,'dw');
pause;

%PSDperiod=zeros(256,256);
FS=256*2;
NW=512;
BlkNum=N/128;
Shift=128;
for i=0:floor(BlkNum-6)
   blk=x(1+i*Shift:i*Shift+NW);
   TmpPSD=UniPSDdb(blk,1,NW,'hanning',FS,'dw');
   %TmpPSD=UniPSDdb(x,1+i*Shift,NW,'hanning',FS,'dw');
   PSDperiod(1:256,i+1)=TmpPSD(1:256,1);
end;

figure;
% PSDperiod=exp(PSDperiod/20);
PSDperiod=PSDperiod+abs(min(min(PSDperiod)));
imshow(PSDperiod,gray(256));
mesh(PSDperiod);

pause;


   



