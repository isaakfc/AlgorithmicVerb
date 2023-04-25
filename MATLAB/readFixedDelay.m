function [out] = readFixedDelay(buffer,n,delay)

% Determine indexes for circular buffer
len = length(buffer);
% Delay index
indexD = mod(n-delay-1,len) + 1; 

% read delayed index
out = buffer(indexD,1);

end
