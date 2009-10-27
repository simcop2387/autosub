function Excitation=ExGenerator(vunv,Pitch,Gain,EGT,N)
% function Excitation=ExGenerator(Voice,Pitch,Gain,EGT)
% Generate the Excitation for LPC synthesizer according
% EGT: The Type of method
% Currently support: 
% 			1.	'2S' ---2 state basic LPCvocoder
%			2. 'wr' ---Wavelet based Residual Excitation LP
% 			3. left for extention;

switch EGT
case '2S'
   Excitation = TSEGenerator (Pitch, vunv, N,Gain);
case 'wr'
   Excitation = WREGenerator;
otherwise
   Excitation = TSEGenerator (Pitch, vunv, N,Gain);	% Default
end

   
   
  