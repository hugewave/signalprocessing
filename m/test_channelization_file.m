clear all;
close all;

% number of taps per channel 
taps = 24;
% number of channels
N = 128;
%K = 11.4;

%npr_coeff(N,L,K);
display('designing prototype filter...');
c=npr_coeff(N*2,taps*2);
c = reshape(c,1,[]);
c = c(1:2:end);
c = reshape(c,N,24);

display('processing...');
fid = fopen('bluetooth_testsig.pcm','r','b');
sig = fread(fid,'int16','l')';
fclose(fid);
csig = sig(1:2:end) + 1j*sig(2:2:end);
csiglen = floor(length(csig)/N)*N;
x = csig(1:csiglen);
y = channelization(c,x);
%%
plot(abs(y(41,:)));
%%