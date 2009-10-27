function Synth=Synthesizer(Excitation,Refl_coef);
% function Synth=Synthesizer(Excitation,Refl_coef);

	Aparm=rc2poly(Refl_coef);
   Synth=filter(1,Aparm,Excitation);
   
   