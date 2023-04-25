clc;
clear all;

% read input audio
[in,Fs] = audioread('Output 1-2.wav');
in(:,1) = [];

% Add extra space at end for the reverb tail
in = [in;zeros(Fs*3,1)];


% apf delay weights to be timsed by a maximum apf time and weighting percent
apfDelayWeight = [ 0.317 0.873 0.477 0.291 0.993, 0.757, 0.179, 0.575 ];

% fixed delay weights to be timsed by a maximum fixed delay time and weighting percent
fixedDelayWeight = [ 1.0 0.873 0.707 0.667 ];

% max apf delay: range from 0ms to 100ms (PARAMETER) 
% (Have to divide by 1000 to work with sample rate which is in seconds)
maxApfDelay = 33/1000;

% Apf delay time weight percent: range from 1 to 100 (PARAMETER)
% need to divide by 100 to give normalised value
apfDelayTimeWeight = 85/100;

% max fixed delay: range from 0ms to 100ms (PARAMETER)
% (Have to divide by1000 to work with sample rate which is in seconds)
maxFixedDelay = 81/1000;

% Fixed delay time weight percent: range from 1 to 100 (PARAMETER)
% need to divide by 100 to give normalised value
fixedDelayTimeWeight = 100/100;

% Apf seed to be multiplied by weight array
ApfSeedSamples = fix(maxApfDelay * apfDelayTimeWeight * Fs);

% Fixed delay seed to be multiplied by weight array
fixedDelaySeedSamples = fix(maxFixedDelay * fixedDelayTimeWeight * Fs);

% Calculate times for apf's
apfDelayTimesSamples = fix(apfDelayWeight * ApfSeedSamples);

% Calculate times for fixed delays
fixedDelayTimesSamples = fix(fixedDelayWeight * fixedDelaySeedSamples);

% set gain for lpf's: range from 0 to 1
dampning = 0.5;

% Initialise buffers
bufferAPF1 = zeros(ApfSeedSamples,1); bufferAPF2 = zeros(ApfSeedSamples,1); 
bufferAPF3 = zeros(ApfSeedSamples,1); bufferAPF4 = zeros(ApfSeedSamples,1);  
bufferAPF5 = zeros(ApfSeedSamples,1); bufferAPF6 = zeros(ApfSeedSamples,1); 
bufferAPF7 = zeros(ApfSeedSamples,1); bufferAPF8 = zeros(ApfSeedSamples,1);  
bufferFixed1 = zeros(fixedDelaySeedSamples,1); bufferFixed2 = zeros(fixedDelaySeedSamples,1);  
bufferFixed3 = zeros(fixedDelaySeedSamples,1); bufferFixed4 = zeros(fixedDelaySeedSamples,1);  


% Set APF gains
innerAPFg = -0.5;
outerAPFg = 0.5;


% Mod APF parameters
% APF1
amp1ModAp = 12;
rate1 = 0.15; 

%APF2
amp3ModAp = 12;
rate3 = 0.33; 

%APF5
amp5ModAp = 10;
rate5 = 0.57; 

%APF7
amp7ModAp = 10;
rate7 = 0.73; 

% Reverb time: range from 0 to 1
Krt = 1;

% Delay percent readings
delayPercentOut = [23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89];

% Global feedback
gFb = 0;

% Parameters lpf 
previousValueLP1 = 0;
previousValueLP2 = 0;
previousValueLP3 = 0;
previousValueLP4 = 0;

% Initialize Output Signal
N = length(in);
out = zeros(N,1);

% For Reverb out 
a = 0;
b = 0;
c = 0;
d = 0;
e = 0;
f = 0;
g = 0;
h = 0;

% Main loop
for n = 1:N
   
    input = in(n,1) + gFb;

    % branch1
    [branch1,bufferAPF1] = apf(input,bufferAPF1,Fs,n,apfDelayTimesSamples(1),outerAPFg,amp1ModAp,rate1);
    [branch1,bufferAPF2] = apfNFb(branch1,bufferAPF2,n,apfDelayTimesSamples(2),innerAPFg); 
    [branch1, previousValueLP1] = onePoleNLPF(branch1,dampning, previousValueLP1);
    [branch1,bufferFixed1] = fixedDelay(branch1,bufferFixed1,n,fixedDelayTimesSamples(1));
    branch1 = branch1 * Krt;
    
    % branch2
    branch2 = in(n,1) + branch1;
    [branch2,bufferAPF3] = apf(branch2,bufferAPF3,Fs,n,apfDelayTimesSamples(3),outerAPFg,amp3ModAp,rate3);
    [branch2,bufferAPF4] = apfNFb(branch2,bufferAPF4,n,apfDelayTimesSamples(4),innerAPFg); 
    [branch2, previousValueLP2] = onePoleNLPF(branch2,dampning, previousValueLP2);
    [branch2,bufferFixed2] = fixedDelay(branch2,bufferFixed2,n,fixedDelayTimesSamples(2));
    branch2 = branch2 * Krt;

    % branch3
    branch3 = in(n,1) + branch2;
    [branch3,bufferAPF5] = apf(branch3,bufferAPF5,Fs,n,apfDelayTimesSamples(5),outerAPFg,amp5ModAp,rate5);
    [branch3,bufferAPF6] = apfNFb(branch3,bufferAPF6,n,apfDelayTimesSamples(6),innerAPFg); 
    [branch3, previousValueLP3] = onePoleNLPF(branch3,dampning, previousValueLP3);
    [branch3,bufferFixed3] = fixedDelay(branch3,bufferFixed3,n,fixedDelayTimesSamples(3));
    branch3 = branch3 * Krt;

    % branch4
    branch4 = in(n,1) + branch3;
    [branch4,bufferAPF7] = apf(branch4,bufferAPF7,Fs,n,apfDelayTimesSamples(7),outerAPFg,amp7ModAp,rate7);
    [branch4,bufferAPF8] = apfNFb(branch4,bufferAPF8,n,apfDelayTimesSamples(8),innerAPFg); 
    [branch4, previousValueLP4] = onePoleNLPF(branch4,dampning, previousValueLP4);
    [branch4,bufferFixed4] = fixedDelay(branch4,bufferFixed4,n,fixedDelayTimesSamples(4));
    branch4 = branch4 * Krt;

    gFb = branch4 * Krt;
    
    % get output data 
    aBufferPos = fix(0.23 * length(bufferFixed1));
    a = readFixedDelay(bufferFixed1, n, aBufferPos);
    bBufferPos = fix(0.41 * length(bufferFixed1));
    b = readFixedDelay(bufferFixed1, n, bBufferPos);

    cBufferPos = fix(0.23 * length(bufferFixed2));
    c = readFixedDelay(bufferFixed2, n, cBufferPos);
    dBufferPos = fix(0.43 * length(bufferFixed2));
    d = readFixedDelay(bufferFixed2, n, dBufferPos);

    eBufferPos = fix(0.59 * length(bufferFixed3));
    e = readFixedDelay(bufferFixed3, n, eBufferPos);
    fBufferPos = fix(0.61 * length(bufferFixed3));
    f = readFixedDelay(bufferFixed3, n, fBufferPos);

    gBufferPos = fix(0.59 * length(bufferFixed4));
    g = readFixedDelay(bufferFixed4, n, gBufferPos);
    hBufferPos = fix(0.61 * length(bufferFixed4));
    h = readFixedDelay(bufferFixed4, n, hBufferPos);

    out(n,1) = (0.125 * a) - (0.125 * b) - (0.125 * c) + (0.125 * d) + (0.125 * e) - (0.125 * f) - (0.125 * g) + (0.125 * h);

end




sound(in,Fs);

