function [WL,WT,Shift,PDT,VDT,LPT,EGT]=InputParms;

global Data FS;

Lx=300;Ly=400;

disp('Input the filename and open it;')

[OFlNam,ODir]=uigetfile('*.wav','Input a .wav file name for LPC encoder',Lx,Ly);
FileNam=strcat(ODir,OFlNam);
Postfix=OFlNam(length(OFlNam)-3:length(OFlNam));
switch Postfix
case '.wav'
	[Data,FS,Bits]=wavread(OFlNam);
   %figure;
   %plot(Data);
case '.mat'
	load OFlNam;   % It should be a *.wav file;
end

WL=0;
while( WL<100|WL>1000 )
	WLst=input('please input the Length of Window:(100-1000)','s');
	WL=str2num(WLst);
end

Shift=0;
while(Shift<10|Shift>WL)
	Shiftst=input('please input the Length of Shift:(10-WL)','s');
	Shift=str2num(Shiftst);
end

WindowType=[
   		'1.hamming ';
         '2.hanning ';
         '3.bartlett';
         '4.triang  ';
         '5.blackman';
         '6:Rectrang'
      ];
      
disp('Type of Window:');
disp(WindowType);      

WT =[];
in=[];
while( ~strcmp(in,'1')&~strcmp(in,'2')&~strcmp(in,'3')&~strcmp(in,'4')&~strcmp(in,'5')&~strcmp(in,'6'))
   in=input('please input the type of Window:','s');
   switch in
   case '1'
      WT='hamming';
   case '2'
      WT='hanning';
   case '3'
      WT='bartlett';
   case '4'
      WT='triang';
   case '5'
      WT='blackman';
   case '6'
      WT='Rectrang';
   end
end

PDType = [
   '1.CentCACF';
   '2.Cesptrum'];
disp('Period Detection Method:');
PDT=[];
while(~strcmp(PDT,'1')&~strcmp(PDT,'2'))
   disp(PDType);
	PDT = input('please input the Period Detection Method:','s');
end

VDType=[
   '1.EnergyT';
   '2.ZeroCro';
	'3.Pattern'];

disp('Voice/unvoiced Decision Method:');
VDT=[];
while(~strcmp(VDT,'1')&~strcmp(VDT,'2')&~strcmp(VDT,'3'))
	disp(VDType);
   VDT = input('please input the Voice/unvoiced Decision Method:','s');
end

EGType=[
   '1.2S';
   '2.WR';
   '3.ER'];

disp('ExcMethod:1.2S -- 2 State, 2.WR-- WRELP,3.RELP(nonproced)');

EGT = input('please input the Excitation Method:','s');
switch EGT
case '1'
   EGT='2S';
case '2'
   EGT='WR';
otherwise
   EGT='ER';
end

LPType=[
   '1.levi';
   '2.burg';];
disp('Linear Prediction Methods');

LPT=[];
while(~strcmp(LPT,'1')&~strcmp(LPT,'2'))
	disp(LPType);   
   LPT = input('please input the Leaner Prediction Method:','s');
end

