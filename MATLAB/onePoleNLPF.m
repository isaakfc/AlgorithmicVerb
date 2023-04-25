function [y, yPrev] = onePoleNLPF(x, alpha, y_prev)
% Implements a dc-normalized one-pole feedback low-pass filter
% Inputs:
%   x: input signal
%   alpha: filter coefficient (0 < alpha < 1)
%   y_prev: previous filter output value (initially set to 0)
% Output:
%   y: filtered output signal

% Calculate current filter output
y = alpha * x + (1 - alpha) * y_prev;

% Normalize filter output to remove DC offset
%y = y - alpha * y_prev;

% Update previous filter output value
yPrev = y;
end