close all;
clear all;

FS=8000;
f0=200;
f1=210;
f2=400;
f3=531;
f4=670;
f5=750;
f6=800;

x(1:FS/8)=sin(2*pi*f0*(1:FS/8)/FS)...
   +(sin(2*pi*f1*(1:FS/8)/FS))...
   +(sin(2*pi*f2*(1:FS/8)/FS))...
   +(sin(2*pi*f3*(1:FS/8)/FS))...
   +(sin(2*pi*f4*(1:FS/8)/FS))...
   +(sin(2*pi*f5*(1:FS/8)/FS))...
   +(sin(2*pi*f6*(1:FS/8)/FS));

y(1:FS/64)=x(1:8:FS/8);
plot(abs(fft(y,FS)));

plot(x);
figure;
psd=abs(fft(x,FS));
plot(psd);
figure;
Rx=xcorr(x);plot(Rx);

[C,L]=wavedec(x,2,'db4');
plot(C);pause;
C(FS/8:FS)=0;
plot(C);
plot(abs(fft(C)));

xr=waverec(C,L,'db4');
figure;
plot(xr);


x(1:FS)=0;
x(1:1000:FS)=1;
plot(x);