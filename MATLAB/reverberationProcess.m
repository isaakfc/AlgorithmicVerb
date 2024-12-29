% --------Algorithmic reverberation process function--------
% Input Parameters:
% in - Input raw audio array
% Fs - Input audio sampling rate
% Mix - mix of dry to wet. Input range from 0 to 100
% er - Early reflections level. Input range from 0 to 100
% preDelay - Amount of delay for wet signal in Ms. Input range from 0 to
% 500ms
% Dampning - Amount of high frequency roll off. Input range from 0 to 100 
% reverbTime - Reverb time parameter. Input range from 0 to 100

function reverberationProcess(in, Fs, mix, er, preDelay, dampning, reverbTime)

% ----INPUT PRE PROCESSING AND PARAMETER INITIALISING---- 

% read input audio
inSter = in;
in(:,1) = [];

% Normalise input audio 
in = in / max(abs(in));

% Add extra space at end for the reverb tail
in = [in;zeros(Fs*20,1)];
inSter = [inSter;zeros(Fs*20,2)];

% Convert pre delay to Ms then to number of samples
preDelay = preDelay / 1000;
preDelay = fix(preDelay*Fs);

% Convert Remaining parameters to normalised values 
mix = mix / 100;
er = er / 100;
dampning = dampning / 100;
reverbTime = reverbTime / 100;

% Flip dampning value
dampning = 1 + dampning*(-1);

% Er compensation gain (was 1.1)
erCompen = 1.45 + er*(1-1.45);

% Dampning compensation gain
DmpCompen = 2.7 + dampning*(1-2.7);


% Scale back user choices 
ERLevel = er;
Krt = 0.5 + reverbTime*(0.99-0.5);


% ----SETTING FILTER WEIGTHS AND TIMES---- 

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

% ----SETTING FILTER WEIGTHS AND TIMES IN SAMPLES---- 

% Apf seed to be multiplied by weight array
ApfSeedSamples = fix(maxApfDelay * apfDelayTimeWeight * Fs);

% Fixed delay seed to be multiplied by weight array
fixedDelaySeedSamples = fix(maxFixedDelay * fixedDelayTimeWeight * Fs);

% Calculate times for apf's
apfDelayTimesSamples = fix(apfDelayWeight * ApfSeedSamples);

% Calculate times for fixed delays
fixedDelayTimesSamples = fix(fixedDelayWeight * fixedDelaySeedSamples);

% Length for ER buffer
ERBufferLength = fix(0.1 * Fs);

% Comb delay times  
combd1 = fix(.0297*Fs); 
combd2 = fix(.0419*Fs); 


% Feedback network delay times
d1FbN = fix(.0297*Fs); 
d2FbN = fix(.0371*Fs); 

% ----INITIALISING BUFFERS---- 

% Initialise APF buffers
bufferAPF1 = zeros(ApfSeedSamples,1); bufferAPF2 = zeros(ApfSeedSamples,1); 
bufferAPF3 = zeros(ApfSeedSamples,1); bufferAPF4 = zeros(ApfSeedSamples,1);  
bufferAPF5 = zeros(ApfSeedSamples,1); bufferAPF6 = zeros(ApfSeedSamples,1); 
bufferAPF7 = zeros(ApfSeedSamples,1); bufferAPF8 = zeros(ApfSeedSamples,1); 

% Initialise Fixed delay buffers
bufferFixed1 = zeros(fixedDelaySeedSamples,1); bufferFixed2 = zeros(fixedDelaySeedSamples,1);  
bufferFixed3 = zeros(fixedDelaySeedSamples,1); bufferFixed4 = zeros(fixedDelaySeedSamples,1);  
bufferER = zeros(ERBufferLength,1);
bufferPreDelay = zeros(Fs,1);

% Initialise comb Fb network buffers
% Max delay of 70 ms
maxDelay = ceil(.07*Fs);  
% Initialize all buffers
bufferFB1 = zeros(maxDelay,1); bufferFB2 = zeros(maxDelay,1); 

% Initialise comb Fb buffers
bufferComb1 = zeros(maxDelay,1);
bufferComb2 = zeros(maxDelay,1);

% ----SET FILTER GAINS---- 

% Set APF gains
innerAPFg = -0.5;
outerAPFg = 0.5;

% Comb gain
combg1 = 0.2;
combg2 = -0.2;

% Fb comb gain
g11 = -0.75; g12 = -0.75;
g21 = -0.75; g22 = -0.75;

% ----SET FILTER MODULATION VALUES---- 

% Mod Comb lfo values
amp1ModComb = 7;
rate1Comb = 0.11; 

amp2ModComb = 10;
rate2Comb = 0.06; 

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

% Fb crossover LFO parameters
rate1FB = 0.6; amp1 = 3; 
rate2FB = 0.71; amp2 = 3;

% ----INITIALISE FEEDBACK VARIABLES---- 

% Global feedback
gFb = 0;

% Fb crossover 
fb1 = 0; fb2 = 0;

% ---INITIALISE VARIABLES FOR USE IN FILTERS---

% Low pass filters previous value
previousValueLP1 = 0;
previousValueLP2 = 0;
previousValueLP3 = 0;
previousValueLP4 = 0;

% Variables used as delay for a simple LPF in each Comb Filter function
fbLPF1 = 0; fbLPF2 = 0; 

% Initial conditions Biquad filter low shelf for feedback paths
% Global feedback
x1Gfb = 0;x2Gfb = 0; y1Gfb = 0;y2Gfb = 0;

% feedback 1
x1fb1 = 0;x2fb1 = 0; y1fb1 = 0;y2fb1 = 0;

% feedback 2
x1fb2 = 0;x2fb2 = 0; y1fb2 = 0;y2fb2 = 0;

% Initial conditions Biquad filter notch feedback paths
x1Gfbn = 0;x2Gfbn = 0; y1Gfbn = 0;y2Gfbn = 0;




% ---INITIALISE VARIABLES FOR USE IN OUTPUT---

% For Reverb out 
a = 0;
b = 0;
c = 0;
d = 0;
e = 0;
f = 0;
g = 0;
h = 0;


% Initialize Output Signal
N = length(in);
out = zeros(N,2);


% Main loop
for n = 1:N
   
    
    % If there is no predelay then just use input 
    if preDelay == 0
        
        preDelayIn = in(n,1);
    
    else
    
        % If there is pre delay then get Pre delayed input
        [preDelayIn,bufferPreDelay] = fixedDelay(in(n,1),bufferPreDelay,n,preDelay);

    end

    preDelayIn = preDelayIn * erCompen * DmpCompen;
    
    % er
    [er , bufferER] = earlyReflectionsSparse(preDelayIn,bufferER,Fs,n, ERLevel);

    % add feedback
    %branch1 = (er + gFb) * erCompen;
    branch1 = (er + gFb);

    % branch1
    [branch1,bufferAPF1] = apf(branch1,bufferAPF1,Fs,n,apfDelayTimesSamples(1),outerAPFg,amp1ModAp,rate1);
    [branch1,bufferAPF2] = apfNM(branch1,bufferAPF2,n,apfDelayTimesSamples(2),innerAPFg); 
    [branch1, previousValueLP1] = onePoleNLPF(branch1,dampning, previousValueLP1);
    [branch1,bufferFixed1] = fixedDelay(branch1,bufferFixed1,n,fixedDelayTimesSamples(1));
    branch1 = branch1 * Krt;
    
    % branch2
    branch2 = preDelayIn + branch1;
    [branch2,bufferAPF3] = apf(branch2,bufferAPF3,Fs,n,apfDelayTimesSamples(3),outerAPFg,amp3ModAp,rate3);
    [branch2,bufferAPF4] = apfNM(branch2,bufferAPF4,n,apfDelayTimesSamples(4),innerAPFg); 
    [branch2,bufferComb1] = lpcf(branch2,bufferComb1,Fs,n,combd1,combg1,amp1ModComb,rate1Comb, fbLPF1);
    [branch2,bufferFixed2] = fixedDelay(branch2,bufferFixed2,n,fixedDelayTimesSamples(2));
    branch2 = branch2 * Krt;

    % branch3
    branch3 = preDelayIn + branch2;
    [branch3,bufferAPF5] = apf(branch3,bufferAPF5,Fs,n,apfDelayTimesSamples(5),outerAPFg,amp5ModAp,rate5);
    [branch3,bufferAPF6] = apfNM(branch3,bufferAPF6,n,apfDelayTimesSamples(6),innerAPFg); 
    [branch3, previousValueLP3] = onePoleNLPF(branch3,dampning, previousValueLP3);
    [branch3,bufferFixed3] = fixedDelay(branch3,bufferFixed3,n,fixedDelayTimesSamples(3));
    branch3 = branch3 * Krt;

    % branch4
    branch4 = preDelayIn + branch3;
    [branch4,bufferAPF7] = apf(branch4,bufferAPF7,Fs,n,apfDelayTimesSamples(7),outerAPFg,amp7ModAp,rate7);
    [branch4,bufferAPF8] = apfNM(branch4,bufferAPF8,n,apfDelayTimesSamples(8),innerAPFg); 
    [branch4,bufferComb2] = lpcf(branch4,bufferComb2,Fs,n,combd2,combg2,amp2ModComb,rate2Comb, fbLPF2);
    [branch4,bufferFixed4] = fixedDelay(branch4,bufferFixed4,n,fixedDelayTimesSamples(4));
    branch4 = branch4 * Krt;

    gFb = branch4;
    [gFb,x1Gfb,x2Gfb,y1Gfb,y2Gfb] = biquadFilterLoop(gFb,Fs,300,0.7,-25 * Krt,'lsf',x1Gfb,x2Gfb,y1Gfb,y2Gfb);
    [gFb,x1Gfbn,x2Gfbn,y1Gfbn,y2Gfbn] = biquadFilterLoop(gFb,Fs,1200,10,-15,'nch',x1Gfbn,x2Gfbn,y1Gfbn,y2Gfbn);
    
    % get output data 
    aBufferPos = fix(0.19 * length(bufferFixed1));
    a = readFixedDelay(bufferFixed1, n, aBufferPos);
    bBufferPos = fix(0.29 * length(bufferFixed1));
    b = readFixedDelay(bufferFixed1, n, bBufferPos);

    cBufferPos = fix(0.37 * length(bufferFixed2));
    c = readFixedDelay(bufferFixed2, n, cBufferPos);
    dBufferPos = fix(0.47 * length(bufferFixed2));
    d = readFixedDelay(bufferFixed2, n, dBufferPos);

    eBufferPos = fix(0.71 * length(bufferFixed3));
    e = readFixedDelay(bufferFixed3, n, eBufferPos);
    fBufferPos = fix(0.67 * length(bufferFixed3));
    f = readFixedDelay(bufferFixed3, n, fBufferPos);

    gBufferPos = fix(0.71 * length(bufferFixed4));
    g = readFixedDelay(bufferFixed4, n, gBufferPos);
    hBufferPos = fix(0.83 * length(bufferFixed4));
    h = readFixedDelay(bufferFixed4, n, hBufferPos);

    inDL1 = er + fb1;
    inDL2 = er + fb2;

    [outDL1,bufferFB1] = modDelay(inDL1,bufferFB1,Fs,n,d1FbN,amp1,rate1FB);
    [outDL1, previousValueLP2] = onePoleNLPF(outDL1,dampning, previousValueLP2);
    [outDL2,bufferFB2] = modDelay(inDL2,bufferFB2,Fs,n,d2FbN,amp2,rate2FB);
    [outDL2, previousValueLP4] = onePoleNLPF(outDL2,dampning, previousValueLP4);

    % Out left
    out(n,1) = (0.1 * a * ERLevel) - (0.1 * c)  + (0.1 * e) - (0.1 * g) + (0.1 * outDL1);

    % Out right
    out(n,2) = - (0.1 * b * ERLevel) + (0.1 * d) - (0.1 * f) + (0.1 * h) - (0.1 * outDL2);
    

    % Calculate Feed-back path1 (including crossover)
    fb1 = 0.5* Krt * (g11 * outDL1 + g21 * outDL2 + branch2); % branch 2
    % Low shelf to avoid excess feedback
    [fb1,x1fb1,x2fb1,y1fb1,y2fb1] = biquadFilterLoop(fb1,Fs,300,0.7,-25 * Krt,'lsf',x1fb1,x2fb1,y1fb1,y2fb1);
    % Calculate Feed-back path2 (including crossover)
    fb2 = 0.5* Krt * (g12 * outDL1 + g22 * outDL2 + branch3); % branch 3
    % Low shelf to avoid excess feedback
    [fb2,x1fb2,x2fb2,y1fb2,y2fb2] = biquadFilterLoop(fb2,Fs,300,0.7,-25 * Krt,'lsf',x1fb2,x2fb2,y1fb2,y2fb2);
   
end


% Add back dry
out = mix * out + (1-mix) * inSter;

sound(out,Fs);




end