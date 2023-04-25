clear;clc;

[in,Fs] = audioread('Output 1-2.wav');
in(:,1) = [];

maxDelay = ceil(.07*Fs);  
buffer1 = zeros(maxDelay,1); buffer2 = zeros(maxDelay,1); 

N = length(in);
out = zeros(N,1);
out2 = zeros(N,1);

d1 = fix(.0297*Fs); g1 = 0.75;
rate1 = 0.6; amp1 = 8;


previousValue = 0;

for n = 1:N
    
    [out(n,1), buffer1] = apf(in(n,1), buffer1, Fs, n, d1, g1, 0, 0);
    [out2(n,1), buffer2] = apfNFb(in(n,1), buffer1, n, d1, g1);
    
end

sound(out, Fs);




