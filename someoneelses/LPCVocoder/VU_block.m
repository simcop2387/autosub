% This function determines whether x is voiced or unvoiced. It also
% determines the pitch period, i.e., 'pperiod', if x is voiced. 
% vu = 1 if voiced and vu = 0 if unvoiced. 

function vu = vunv_block(x,B,A)

K = 0.6;                           % clipping factor
x = x .* hamming(length(x));       % windowing data
fltx = filter(B,A,x);              % filtering data


fthrd = 1:round(length(fltx)/3);   % first third indices
fmax1 = max(abs(fltx(fthrd)));

sthrd = (length(fltx)-length(fthrd)):length(fltx);  % last third indices
fmax2 = max(abs(fltx(sthrd)));

C = K*min([fmax1 fmax2]);          % clipping value 

fltx = (fltx - C*sign(fltx)).*(fltx > C | fltx < -C);   % clipping

E=0;                               % initial value of energy measure.

for i=1: length(fltx)              % calculate the energy of clipped data within one block.
   E=E+fltx(i)^2;
end

E=sqrt(E);

if (E > 3.0e+3)                     % energy profile exceeds a conservative threshold. 
   vu = 1;                          % voiced.
else
   vu = 0;                          % unvoiced.
end;
    


