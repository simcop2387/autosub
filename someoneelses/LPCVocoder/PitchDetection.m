function PitchPer= PitchDetection(Data,PDT)
% function PitchPer= PitchDetection(Data,PDT)
% Do the Pitch detection according the method PDT
% Now PDT = 'CentCACF'
% 			 = 'Cesptrum'
% Supported.

switch PDT
case '1'	% The center clip and autocorrelation pitch determination
   slope = 10;		% What is this slope?
   PitchPer = pitchCent(Data, slope);
case '2'
   PitchPer = pitchCeps(Data);
end
    
   