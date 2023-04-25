clear;clc;

[in,Fs] = audioread('Output 1-2.wav');
in(:,1) = [];

N = length(in);
out = zeros(N,1);

previousValue = 0;

for n = 1:N
    
    [out(n,1), previousValue] = onePoleNLPF(in(n,1), 1.2, previousValue);
    
end
sound(out,Fs);