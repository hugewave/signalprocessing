clear all;
clc;
fid = fopen('onehop_200M.pcm','r','b');
sig = fread(fid,'int16','l')';
fclose(fid);
fs = 200e6;
fftlen = 1024;
[fc,bw,peak_2_avg] = single_hop_est(sig,fs,fftlen);