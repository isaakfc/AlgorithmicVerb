
function [out,buffer] = apfDirectForm2Mod(in,buffer,Fs,n,delay,gain,amp,rate)

% fractional delay
t = (n-1)/Fs;
fracDelay = amp * sin(2*pi*rate*t);
intDelay = floor(fracDelay); 
frac = fracDelay - intDelay; 

len = length(buffer);
indexC = mod(n-1,len) + 1; 
indexD = mod(n-delay-1+intDelay,len) + 1; 
indexF = mod(n-delay-1+intDelay+1,len) + 1;

wDelay = (1-frac)*buffer(indexD,1) + (frac)*buffer(indexF,1);

% This would be y[n] = g * x[n] + w[n-1]
out = gain * in(n,1) + wDelay;

% This would be w[n] = (-g) * y[n] + x[n]
w = in(n,1) +  gain*out;


% Update the buffer with the current input and output
buffer(indexC,1) = w;


end






