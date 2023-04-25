clear;clc;

[in,Fs] = audioread('Output 1-2.wav');
in(:,1) = [];

% mix
mix = 0.7;

% Add extra space at end for the reverb tail
in = [in;zeros(Fs*20,1)]; 

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
buffer13 = zeros(maxDelay,1); buffer14 = zeros(maxDelay,1);  
buffer15 = zeros(maxDelay,1); buffer16 = zeros(maxDelay,1);  


% ap no mod parameters
d1Ap = fix((1/210)*Fs); g1 = 0.5;
d2Ap = fix((79/22050)*Fs); g2 = 0.5;
d3Ap = fix((379/44100)*Fs); g3 = 0.5;
d4Ap = fix((5000/4410)*Fs); g4 = 0.5;
d5Ap = fix((3931/44100)*Fs); g5 = 0.5;
d6Ap = fix((4000/1225)*Fs); g6 = 0.5;
d7Ap = fix((3931/44100)*Fs); g7 = 0.5;
d8Ap = fix((74/1225)*Fs); g8 = 0.5;

% fixed delay parameters 
d1Fixed = fix((6241/44100)*Fs);
d2Fixed = fix((4590/44100)*Fs);
d3Fixed = fix((3641/44100)*Fs);
d4Fixed = fix((2000/44100)*Fs);
d5Fixed = fix((6000/44100)*Fs);
d6Fixed = fix((1000/44100)*Fs);
d7Fixed = fix((4300/44100)*Fs);
d8Fixed = fix((5999/44100)*Fs);

% Parameter
gain5 = 0.7;

% Feedback
fb1 = 0;
fb2 = 0;
fb3 = 0;
fb4 = 0;

% Output points

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
out = zeros(N,1);



% Main loop
for n = 1:N
    
   % initialise parallel chains 

   parallel1 = in(n,1) + fb4;
   parallel2 = in(n,1) + fb1;
   parallel3 = in(n,1) + fb2;
   parallel4 = in(n,1) + fb3;

   % parallel chain 1
   [parallel1,buffer1] = apfNFb(parallel1,buffer1,n,d1Ap,g1); 
   [parallel1,buffer2] = apfNFb(parallel1,buffer2,n,d1Ap,g2); 
   [a,buffer3] = fixedDelay(parallel1,buffer3,n,d1Fixed);
   [b,buffer4] = fixedDelay(parallel1,buffer4,n,d2Fixed);
   fb1 = 0.25 * (b * gain5);

   % parallel chain 2
   [parallel2,buffer5] = apfNFb(parallel2,buffer5,n,d3Ap,g3); 
   [parallel2,buffer6] = apfNFb(parallel2,buffer6,n,d4Ap,g4); 
   [c,buffer7] = fixedDelay(parallel2,buffer7,n,d3Fixed);
   [d,buffer8] = fixedDelay(parallel2,buffer8,n,d4Fixed);
   fb2 = 0.25 * (d * gain5);
   
   % parallel chain 3
   [parallel3,buffer9] = apfNFb(parallel3,buffer9,n,d5Ap,g5); 
   [parallel3,buffer10] = apfNFb(parallel3,buffer10,n,d6Ap,g6);
   [e,buffer11] = fixedDelay(parallel3,buffer11,n,d5Fixed);
   [f,buffer12] = fixedDelay(parallel3,buffer12,n,d6Fixed);
   fb3 = 0.25 * (f * gain5);

   % parallel chain 4
   [parallel4,buffer13] = apfNFb(parallel4,buffer13,n,d7Ap,g7); 
   [parallel4,buffer14] = apfNFb(parallel4,buffer14,n,d8Ap,g8); 
   [g,buffer15] = fixedDelay(parallel4,buffer15,n,d7Fixed);
   [h,buffer16] = fixedDelay(parallel4,buffer16,n,d8Fixed);
   fb4 = 0.25 * (h * gain5);


   out(n,1) = (a*0.125) + (b*0.125) + (c*0.125) + (d * 0.125) + (e * 0.125) + (f * 0.125) + (g * 0.125) + (h * 0.125);
    
    
end

    % pre delay
    out = [zeros(length(preDelay)); out];
    in = [in; zeros(length(preDelay))];
    out = mix * out + (1-mix) * in;













sound(out,Fs);