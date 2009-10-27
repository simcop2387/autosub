function [period] = pitchCeps (x)         % cepstrum
                                       % pitch determination
if (length(x)<3) 
   period=0;
else

xfft=abs(fft(x));
logfft=log(xfft);
ceps=ifft(logfft);
[cmax,ind]=max(ceps);
period=ind;

end;   

