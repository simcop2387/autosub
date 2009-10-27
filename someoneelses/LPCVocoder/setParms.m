function setParms(action)

global WL WT LPT VDT PDT;
global HdWL HdWT HdLPT HdVDT HdPDT;

HdObj=gca;	% Handle of current Object;
switch action
case 'WL'
   WL=get(HdObj,'string');
   WL=str2num(WL);
   % Other operations comes here
case 'WT'
   WT=get(HdObj,'UserData');
case 'LPT'
   LPT=get(HdObj,'UserData');
case 'VDT'
   VDT=get(HdObj,'UserData');
case 'PDT'
   PDT=get(HdObj,'UserData');
end

disp('setParms')
%LPCmain('ParmSet');