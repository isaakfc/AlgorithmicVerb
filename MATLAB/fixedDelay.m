function [out,buffer] = fixedDelay(in,buffer,n,delay)

% Determine indexes for circular buffer
len = length(buffer);
indexC = mod(n-1,len) + 1; % Current index 
indexD = mod(n-delay-1,len) + 1; % Delay index

out = buffer(indexD,1);

% Store the current output in appropriate index
buffer(indexC,1) = in;

end