[in,Fs] = audioread("strings.wav");

% Hall 
reverberationProcess(in,Fs,40,50,100,70,80);


% Cathedral
%reverberationProcess(in,Fs,40,20,50,30,90);

% Spring
%reverberationProcess(in,Fs,40,0,0,90,70);