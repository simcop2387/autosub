function [block]=TSEGenerator (vunv,pitch,Gain,N)  %N-length of block

%sequence to mimic actual voice excitations (http://www.dsp.rice.edu/courses/elec532/PROJECTS96/lpc/code.html)
grlo = [ 249 -262 363 -362 100 367 79 78 10 -277 82 376 288 -65 -20 138 -62 -315 -247 -78 -82 -123 -39 65 64 19 16 32 18 -15 -29 -21 -18 -27 -31 -22 -12 -10 -10 -4];

if ( vunv ==0 )                             % if unvoiced 
      block = randn(1,N)*Gain;					  % return noise
     % if (pitch==0)												% if voiced
       %  block = randn(1,N)*Gain;
else

pom = zeros(1,N+length(grlo));                

      for l = 1:floor(N/pitch)
         brojac = (l-1)*pitch;
         pom((brojac+1):(brojac+length(grlo)))=grlo;    
      end      
      block=pom(1:N);
      kk=std(block);
      if (kk==0)
         block=Gain*block;
      else
         block=Gain*block/kk;				% normalize variance
      end
end

