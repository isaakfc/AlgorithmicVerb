function [out, buffer] = apfDirectForm2(in, buffer, n, delay, gain)

% Determine indexes for circular buffer
len = length(buffer);
indexC = mod(n-1,len) + 1; % Current index 
indexD = mod(n-delay-1,len) + 1; % Delay index

% Retrieve the delayed output from the buffer
wDelay = buffer(indexD,1);

% This would be y[n] = g * x[n] + w[n-1]
out = gain * in(n,1) + wDelay;

% This would be w[n] = (-g) * y[n] + x[n]
w = in(n,1) + -gain*out;


% Update the buffer with the current input and output
buffer(indexC,1) = w;

end