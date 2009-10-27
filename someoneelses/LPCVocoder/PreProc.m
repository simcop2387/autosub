function [WData,w]=PreProc(OBlkData,WT,WL);
% function WData=PreProc(OBlkData,WT,WL);
% Do preprocessing to the Data
% This includes the following steps:
% 1.Preemphasis;
% 2.Windowing;
% 3.May include other preprocessing routines here.

% The LPC10E demo for reference
% pebuf( mid+1:hi )                = preemp( inbuf( mid + 1 : hi ), 0.4 );
% function out = preemp( in, coef )
% DECLARE GLOBALS
% global zpre;
% INITIALIZE PREEMPHASIS TAPS - DUPLICATE LPC 55 SOURCE
% b = [ 1.0, -1.0, coef ];
% a = [ 1.0, 0.0, 0.0 ];
% APPLY PREEMPHASIS FILTER TO INPUT FRAME
% [ out, zpre ] = filter( b, a, in, zpre );


WData=filter([1,-0.9375],1,OBlkData);
if strcmp(WT,'Rectrang')
   w=ones(WL,1);
else
   winfun=strcat(WT,'(');
   winfun=strcat(winfun,'WL');
   winfun=strcat(winfun,')');
   w=eval(winfun);		% Get the window data;
end

WData=WData.*w;

return;
