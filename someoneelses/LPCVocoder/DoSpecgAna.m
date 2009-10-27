function DoSpecgAna
% function DoSpecgAna

global WL WT Shift PDT VDT LPT;
global Data FS;

figure;
N=length(Data);
PSDbs=UniPSDdb(Data,1,N,WT,FS,'bs');

BlkNum=N/Shift;
FS1=512;
figure;
for i=0:floor(BlkNum-6)
   blk=Data(1+i*Shift:i*Shift+WL);
   TmpPSD=UniPSDdb(blk,1,WL,WT,FS1,'dw');
   %TmpPSD=UniPSDdb(x,1+i*Shift,NW,'hanning',FS,'dw');
   PSDperiod(1:FS1/2,i+1)=TmpPSD(1:FS1/2,1);
   Progprompt=strcat('Processing frame #:',num2str(i));
   disp(Progprompt);
end;

figure;

PSDperiod=PSDperiod+abs(min(min(PSDperiod)));
imshow(PSDperiod,gray(256));colormap(jet);
figure; mesh(PSDperiod);colormap(jet);

sv=input('Save the result (y|n)?','s');
switch sv
case 'y'
   svfl=input('Input the file to save result:','s');
   save svfl;
otherwise
   return;
end


