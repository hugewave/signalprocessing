clear all;
clc;
fid = fopen('onehop.pcm','r','b');
sig = fread(fid,'int16','l')';
fclose(fid);
fs = 200e6;
fftlen = 1024;
search_results = freq_domain_sig_search(sig,fs,fftlen);
%[fc,bw,peak_2_avg] = single_hop_est(sig,fs,fftlen);