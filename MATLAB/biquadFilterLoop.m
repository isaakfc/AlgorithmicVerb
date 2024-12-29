% BIQUADFILTER
% This function implements a bi-quad filter based
% on the Audio EQ Cookbook Coefficients. All filter
% types can be specified (LPF, HPF, BPF, etc.) and
% three different topologies are included.
%
% Input Variables
%   f0 : filter frequency (cut-off or center based on filter)
%   Q : bandwidth parameter 
%   dBGain : gain value on the decibel scale
%   type : 'lpf','hpf','pkf','bp1','bp2','apf','lsf','hsf'
%   form : 1 (Direct Form I), 2 (DFII), 3 (Transposed DFII)

function [out,x1,x2,y1,y2] = biquadFilterLoop(in,Fs,f0,Q,dBGain,type,x1, x2, y1, y2)


%%% Intermediate Variables
%
w0 = 2*pi*f0/Fs;            % Angular Freq. (Radians/sample) 
alpha = sin(w0)/(2*Q);      % Filter Width
A  = sqrt(10^(dBGain/20));  % Amplitude

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TYPE - LPF,HPF,BPF,APF,HSF,LSF,PKF,NCH
%
%----------------------
%        LPF
%----------------------
if strcmp(type,'lpf')
    b0 =  (1 - cos(w0))/2;
    b1 =   1 - cos(w0);
    b2 =  (1 - cos(w0))/2;
    a0 =   1 + alpha;
    a1 =  -2*cos(w0);
    a2 =   1 - alpha;

%----------------------
%        HPF
%----------------------
elseif strcmp(type,'hpf')
    b0 =  (1 + cos(w0))/2;
    b1 = -(1 + cos(w0));
    b2 =  (1 + cos(w0))/2;
    a0 =   1 + alpha;
    a1 =  -2*cos(w0);
    a2 =   1 - alpha;

%----------------------
%   Peaking Filter
%----------------------
elseif strcmp(type,'pkf')
    b0 =   1 + alpha*A;
    b1 =  -2*cos(w0);
    b2 =   1 - alpha*A;
    a0 =   1 + alpha/A;
    a1 =  -2*cos(w0);
    a2 =   1 - alpha/A;

%----------------------
%   Band-pass Filter 1
%----------------------
% Constant skirt gain, peak gain = Q
elseif strcmp(type,'bp1')
    b0 =   sin(w0)/2;
    b1 =   0;
    b2 =  -sin(w0)/2;
    a0 =   1 + alpha;
    a1 =  -2*cos(w0);
    a2 =   1 - alpha;

%----------------------
%   Band-pass Filter 2
%----------------------
% Constant 0 dB peak gain
elseif strcmp(type,'bp2')
    b0 =   alpha;
    b1 =   0;
    b2 =  -alpha;
    a0 =   1 + alpha;
    a1 =  -2*cos(w0);
    a2 =   1 - alpha;

%----------------------
%    Notch Filter
%----------------------
elseif strcmp(type,'nch')
    b0 =   1;
    b1 =  -2*cos(w0);
    b2 =   1;
    a0 =   1 + alpha;
    a1 =  -2*cos(w0);
    a2 =   1 - alpha;        

%----------------------
%    All-Pass Filter
%----------------------
elseif strcmp(type,'apf')
    b0 =   1 - alpha;
    b1 =  -2*cos(w0);
    b2 =   1 + alpha;
    a0 =   1 + alpha;
    a1 =  -2*cos(w0);
    a2 =   1 - alpha;

%----------------------
%    Low-Shelf Filter
%----------------------
elseif strcmp(type,'lsf')
    b0 = A*((A+1) - (A-1)*cos(w0) + 2*sqrt(A)*alpha);
    b1 = 2*A*((A-1) - (A+1)*cos(w0));
    b2 = A*((A+1) - (A-1)*cos(w0) - 2*sqrt(A)*alpha);
    a0 = (A+1) + (A-1)*cos(w0) + 2*sqrt(A)*alpha;
    a1 = -2*((A-1) + (A+1)*cos(w0));
    a2 = (A+1) + (A-1)*cos(w0) - 2*sqrt(A)*alpha;

%----------------------
%    High-Shelf Filter
%----------------------
elseif strcmp(type,'hsf')
    b0 = A*( (A+1) + (A-1)*cos(w0) + 2*sqrt(A)*alpha);
    b1 = -2*A*((A-1) + (A+1)*cos(w0));
    b2 = A*((A+1) + (A-1)*cos(w0) - 2*sqrt(A)*alpha);
    a0 = (A+1) - (A-1)*cos(w0) + 2*sqrt(A)*alpha;
    a1 = 2*((A-1) - (A+1)*cos(w0));
    a2 = (A+1) - (A-1)*cos(w0) - 2*sqrt(A)*alpha;

% Otherwise, no filter
else 
    b0 = 1; a0 = 1;
    b1 = 0; b2 = 0; a1 = 0; a2 = 0;
end

out = (b0/a0)*in + (b1/a0)*x1 + (b2/a0)*x2 ...
            + (-a1/a0)*y1 + (-a2/a0)*y2;
x2 = x1;
x1 = in;
y2 = y1;
y1 = out;


end
