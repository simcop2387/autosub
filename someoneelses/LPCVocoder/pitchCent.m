function [period] = pitchCent(x, slope)       % center clip and autocorrelation 
                                              % pitch determination
if ((length(x)<3)|(slope<1)) 
   period=0;
else
K = 0.6;                           % clipping factor

fthrd = 1:round(length(x)/3);   % first third indices
fmax1 = max(abs(x(fthrd)));

sthrd = (length(x)-length(fthrd)):length(x);  % last third indices
fmax2 = max(abs(x(sthrd)));

C = K*min([fmax1 fmax2]);          % clipping value 

x = (x - C*sign(x)).*((x > C | x < -C)*slope);   % clipping


cor = xcorr(x);
[amax,ind] = max(cor);              % maximum correlation value at center

rcor = cor(ind:length(cor));        % right half of original correlation
% stem(rcor(1:100)); pause;

start = find(rcor < .3*amax);       
start = max([20 start(1)]);


[cmax,ind] = max(rcor(start:length(rcor)));

if (cmax > 0.3*amax)
   period = ind + start - 1;  
else
   period = 0;  
end
 end;   

