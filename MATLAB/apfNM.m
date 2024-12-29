function [out,buffer] = apfNM(in,buffer,n,delay,gain)



% Determine indexes for circular buffer
len = length(buffer);
indexC = mod(n-1,len) + 1; % Current index 
indexD = mod(n-delay-1,len) + 1; % Delay index


% Temp variable for output of delay buffer
w = buffer(indexD,1);

% Temp variable used for the node after the input sum
v = in + (-gain*w);

% Summation at output
out = (gain * v) + w;

% Store the current input to delay buffer
buffer(indexC,1) = v;

end