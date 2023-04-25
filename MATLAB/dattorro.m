clear;clc;

[in,Fs] = audioread('Output 1-2.wav');
in(:,1) = [];
% Add extra space at end for the reverb tail
in = [in;zeros(Fs*3,1)]; 

% Set pre delay
preDelay = fix(1.5*Fs);

% Max delay of 70 ms
maxDelay = ceil(.07*Fs);  

% LPF prev val
lpf1PrevVal = 0; lpf2PrevVal = 0; lpf3PrevVal = 0;

% Initialize all buffers
buffer1 = zeros(maxDelay,1); buffer2 = zeros(maxDelay,1); 
buffer3 = zeros(maxDelay,1); buffer4 = zeros(maxDelay,1);  
buffer5 = zeros(maxDelay,1); buffer6 = zeros(maxDelay,1); 
buffer7 = zeros(maxDelay,1); buffer8 = zeros(maxDelay,1);  
buffer9 = zeros(maxDelay,1); buffer10 = zeros(maxDelay,1);  
buffer11 = zeros(maxDelay,1); buffer12 = zeros(maxDelay,1);  


% ap no mod parameters
d1Ap = fix((1/210)*Fs); g1 = 0.75;
d2Ap = fix((79/22050)*Fs); g2 = 0.75;
d3Ap = fix((379/44100)*Fs); g3 = 0.625;
d4Ap = fix((41/4410)*Fs); g4 = 0.625;
d5Ap = fix((3931/44100)*Fs); g5 = 0.5;
d6Ap = fix((74/1225)*Fs); g6 = 0.5;

% fixed delay parameters 
d1Fixed = fix((6241/44100)*Fs);
d2Fixed = fix((6590/44100)*Fs);
d3Fixed = fix((4641/44100)*Fs);
d4Fixed = fix((5505/44100)*Fs);


% Mod APF parameters
d1ModAp = fix((1343/44100)*Fs);
g1ModAp = 0.7;
amp1ModAp = 12;
rate1 = 0.6; 

d2ModAp = fix((995/44100)*Fs);
g2ModAp = 0.7;
amp2ModAp = 12;
rate2 = 0.71;

% Parameters lpf 
previousValueLP1 = 0;
previousValueLP2 = 0;
previousValueLP3 = 0;
bw = 0.9;
de = 0.9;
gain5 = 0.8;

% Feedback
fb1 = 0;
fb2 = 0;


% Initialize Output Signal
N = length(in);
out = zeros(N,1);



% Main loop
for n = 1:N
    
   % process through a LPF then 4 all pass filters
   [temp, previousValueLP1] = onePoleNLPF(in(n,1),bw, previousValueLP1);
   [temp,buffer1] = apfNFb(temp,buffer1,n,d1Ap,g1); 
   [temp,buffer2] = apfNFb(temp,buffer2,n,d2Ap,g2); 
   [temp,buffer3] = apfNFb(temp,buffer3,n,d3Ap,g3); 
   [temp,buffer4] = apfNFb(temp,buffer4,n,d4Ap,g4);
   % start paralell processing
   parallel1 = temp;
   parallel2 = temp;
   parallel1 = parallel1 + fb2;
   [parallel1,buffer5] = apf(parallel1,buffer5,Fs,n,d1ModAp,g1ModAp ,amp1ModAp,rate1);
   [a,buffer6] = fixedDelay(temp,buffer6,n,d1Fixed);
   [b, previousValueLP2] = onePoleNLPF(a,de, previousValueLP2);
   b = b * gain5;
   [b,buffer7] = apfNFb(b,buffer7,n,d5Ap,g5); 
   [c,buffer8] = fixedDelay(b,buffer8,n,d2Fixed);
   % start paralell processing 2nd branch
   parallel2 = parallel2 + fb1;
   [d,buffer9] = apf(parallel2,buffer9,Fs,n,d2ModAp,g2ModAp ,amp2ModAp,rate2);
   [d,buffer10] = fixedDelay(d,buffer10,n,d3Fixed);
   [e, previousValueLP3] = onePoleNLPF(d,de, previousValueLP3);
   e = e * gain5;
   [e,buffer11] = apfNFb(e,buffer11,n,d6Ap,g6); 
   [f,buffer12] = fixedDelay(e,buffer12,n,d4Fixed);

   
   out(n,1) = (a*0.16) + (b*0.16) + (c*0.16) + (d * 0.16) + (e * 0.16) + (f * 0.16);
   fb1 = 0.5*(gain5 * c);
   fb2 = 0.5*(gain5 * f);
    
    
end















sound(out,Fs);


