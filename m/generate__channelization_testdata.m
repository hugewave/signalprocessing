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

display('generating a test signal...');
M = 4096; % number of slices
% generate a linear chirp as a test signal.
% matlab's own chirp function has too much phase noise
% so we use our own version!
t=(0:M*N-1)/(M*N);
dphi=t;
phi=zeros(size(dphi));
for i=2:length(dphi);
    phi(i) = mod(phi(i-1)+dphi(i-1),1);
end
x = exp(-sqrt(-1)*2*pi*phi);
length(x)
% add some white noise if you like
%x = awgn(x,200);

% run it through the npr filterbank
display('processing...');
y = channelization(c,x);

figure();

img=20*log10(abs(y(1:size(y,1),1:size(y,2))));
imagesc(img);
colorbar;
title('spectrogram (dB)');
xlabel('time (slice)');
ylabel('frequency (channel)');

%generate files, and write DATAs into it for Verilog code testing

fid = fopen('xcoeff.txt','w');
[ro co] = size(c)
for col = 1 :co
    for row = 1 : ro
        t = round(c(row,col)*(2^24));
        if t >= 0
            tmp = t;
        else 
            tmp = -t;
            tmp = bitxor(2^32-1,tmp);
            tmp = tmp + 1;
        end
        
        str = sprintf('%08x',tmp);
        fprintf(fid,'%s\r\n',str);
    end
end
fclose(fid);


fid = fopen('xdata.txt','w');
[ro co] = size(x)
for i=1:ro*co
    re = round(real(x(i))*(2^13));
    im = round(imag(x(i))*(2^13));
    if re >= 0
        Re = re;
    else 
        Re = -re;
        Re = bitxor(2^16-1,Re);
        Re = Re + 1;
    end
    
    if im >= 0
        Im = im;
    else 
        Im = -im;
        Im = bitxor(2^16-1,Im);
        Im = Im + 1;
    end
    
    xdata = Im*65536 + Re;
    str = sprintf('%08x',xdata);
    fprintf(fid,'%s\r\n',str);
end
fclose(fid);



