function [W,m]=GetPara_training

load -ascii training_m.dat
m=training_m;

load -ascii training_w1.dat
W(:,:,1)=training_w1;

load -ascii training_w2.dat
W(:,:,2)=training_w2;

load -ascii training_w3.dat
W(:,:,3)=training_w3;

